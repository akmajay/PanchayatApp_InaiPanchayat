import '../../../core/supabase_client.dart';

/// Service to handle remote configuration from Supabase
class ConfigService {
  ConfigService._();
  static final ConfigService instance = ConfigService._();

  /// Fetch a config value by key
  Future<String?> getConfigValue(String key) async {
    try {
      final response = await supabase
          .from('pp_config')
          .select('value')
          .eq('key', key)
          .maybeSingle();

      if (response == null) return null;
      return response['value'] as String?;
    } catch (e) {
      // Quiet fail to avoid app crash on config fetch
      return null;
    }
  }

  /// Get minimum required app version
  Future<String> getMinAppVersion() async {
    final version = await getConfigValue('min_app_version');
    return version ?? '1.0.0'; // Default to 1.0.0 if fetch fails
  }
}
