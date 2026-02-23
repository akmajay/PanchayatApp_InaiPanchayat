import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_constants.dart';
import '../../../core/router/routes.dart';
import '../../auth/widgets/government_disclaimer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About App (ऐप के बारे में)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // App Icon Placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_outlined,
                size: 64,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppInfo.appName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Built for Community, by Community\n(समुदाय के लिए, समुदाय द्वारा निर्मित)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            _buildAboutTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy (गोपनीयता नीति)',
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            _buildAboutTile(
              context,
              icon: Icons.gavel_outlined,
              title: 'Terms of Service (सेवा की शर्तें)',
              onTap: () => context.push(AppRoutes.termsOfService),
            ),
            _buildAboutTile(
              context,
              icon: Icons.description_outlined,
              title: 'View Licenses (लाइसेंस देखें)',
              subtitle: 'Third-party library information',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppInfo.appName,
                  applicationVersion: '1.0.0',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  applicationLegalese: '© 2026 PanchayatApp Team',
                );
              },
            ),
            
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: GovernmentDisclaimer(compact: true),
            ),
            const SizedBox(height: 48),
            Text(
              'Made with ❤️ in India',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}
