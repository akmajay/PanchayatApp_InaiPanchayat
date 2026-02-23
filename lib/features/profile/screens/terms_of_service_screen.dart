import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service (सेवा की शर्तें)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: February 2026',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By using ${AppInfo.appName}, you agree to these terms. This app is a community platform and is NOT an official government application.',
            ),
            _buildSection(
              theme,
              '2. Prohibited Content (प्रतिबंधित सामग्री)',
              'Users are strictly forbidden from posting content that involves:\n'
              '• Character assassination of public officials or individuals.\n'
              '• Personal extortion, blackmail, or intimidation.\n'
              '• Spreading communal disharmony or hate speech.\n'
              '• Obscene or sexually explicit material.',
            ),
            _buildSection(
              theme,
              '3. Zero Tolerance for Extortion',
              'We have a zero-tolerance policy for extortion. Any user attempting to use this platform to blackmail officials or citizens will be permanently banned and reported to legal authorities.',
            ),
            _buildSection(
              theme,
              '4. Legal Compliance (कानूनी अनुपालन)',
              'In compliance with Indian IT Intermediary Rules, we will provide access logs and user data to legal authorities if required by a valid court order or government warrant.',
            ),
            _buildSection(
              theme,
              '5. Limitation of Liability',
              '${AppInfo.appName} is not responsible for the accuracy of user-generated grievances. Users are solely responsible for the content they post.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
