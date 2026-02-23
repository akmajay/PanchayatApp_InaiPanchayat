import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'core/services/cache_service.dart';
import 'core/supabase_client.dart';
import 'core/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/error_screen.dart';
import 'features/posts/services/block_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/services/config_service.dart';
import 'shared/widgets/force_update_screen.dart';

void main() {
  // Catch errors in the Flutter framework
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Log to external service (Sentry/Bugsnag) here if needed
  };

  // Define a custom error widget for production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return AppErrorScreen(details: details);
  };

  runZonedGuarded(
    () async {
      // Ensure Flutter bindings are initialized
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // Force a hard timeout for initialization to prevent splash hang
      final updateRequired = await Future.any([
        _initApp(),
        Future.delayed(const Duration(seconds: 8)).then((_) => false), // 8 second hard limit
      ]);

      // Run app wrapped in ProviderScope for Riverpod
      runApp(ProviderScope(
        child: PanchayatApp(updateRequired: updateRequired),
      ));
    },
    (error, stack) {
      // Initialization error — log to crash reporting service in production.
      runApp(const ProviderScope(child: PanchayatApp(updateRequired: false)));
    },
  );
}

/// Consolidated initialization logic
/// Returns true if force update is required
Future<bool> _initApp() async {
  bool updateRequired = false;
  try {
    // 1. Initialize Supabase (Critical for Auth)
    if (SupabaseConfig.isConfigured) {
      await SupabaseConfig.initialize();
    }

    // 2. Initialize Cache (Hive init + open all boxes)
    await CacheService.instance.init();

    // 3. Initialize BlockService (depends on Supabase + Hive)
    final blockService = BlockService();
    await blockService.init(); // Opens 'blocked_users'
    await blockService.syncBlocks();

    try {
      await Firebase.initializeApp();
      await NotificationService.instance.init();
    } catch (_) {
      // FCM initialization failed — non-critical, continue.
    }

    // 5. Check for updates
    try {
      final minVersion = await ConfigService.instance.getMinAppVersion();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      updateRequired = _isVersionLower(currentVersion, minVersion);
    } catch (_) {
      // Update check failed — non-critical, continue.
    }
  } catch (_) {
    // Service initialization failed — log to crash reporting in production.
  }
  return updateRequired;
}

/// Helper to compare semantic versions (e.g., 1.0.1 < 1.1.0)
bool _isVersionLower(String current, String minimum) {
  try {
    final currentParts = current.split('.').map(int.parse).toList();
    final minParts = minimum.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final currentVal = i < currentParts.length ? currentParts[i] : 0;
      final minVal = i < minParts.length ? minParts[i] : 0;

      if (currentVal < minVal) return true;
      if (currentVal > minVal) return false;
    }
    return false;
  } catch (e) {
    return false;
  }
}

/// Root application widget using GoRouter
class PanchayatApp extends ConsumerStatefulWidget {
  final bool updateRequired;
  const PanchayatApp({super.key, this.updateRequired = false});

  @override
  ConsumerState<PanchayatApp> createState() => _PanchayatAppState();
}

class _PanchayatAppState extends ConsumerState<PanchayatApp> {
  @override
  void initState() {
    super.initState();
    // Remove splash screen after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get router from provider
    final router = ref.watch(routerProvider);

    if (widget.updateRequired) {
      return MaterialApp(
        title: AppInfo.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const ForceUpdateScreen(),
      );
    }

    return MaterialApp.router(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
