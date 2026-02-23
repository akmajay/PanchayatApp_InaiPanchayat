import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy (गोपनीयता नीति)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: February 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            SelectableText.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  _buildRichHeader(theme, '1. Introduction (परिचय)\n'),
                  const TextSpan(
                    text: 'PanchayatApp is committed to protecting your privacy. This policy explains how we collect and use your data in compliance with the IT Act 2000 of India.\n\n',
                  ),
                  _buildRichHeader(theme, '2. No Data Selling (डेटा बेचना मना है)\n'),
                  const TextSpan(
                    text: 'We strictly DO NOT sell, rent, or trade your personal information with third-party advertisers. Your data is used exclusively to provide and improve the app\'s community features.\n\n',
                  ),
                  _buildRichHeader(theme, '3. Data Security (डेटा सुरक्षा)\n'),
                  const TextSpan(
                    text: 'All personal information and media (photos/videos) are stored on secure servers with industry-standard encryption. We use secure connections (HTTPS) whenever data is sent or received by the app.\n\n',
                  ),
                  _buildRichHeader(theme, '4. Automatic Video Cleanup (वीडियो साक्ष्य हटाना)\n'),
                  const TextSpan(
                    text: 'To protect privacy and respect your storage, all evidence videos recorded for grievance proof are strictly for validation only and are automatically purged from our secure servers within 24 hours.\n\n',
                  ),
                  _buildRichHeader(theme, '5. Your Control (आपका नियंत्रण)\n'),
                  const TextSpan(
                    text: '• You can update your profile details at any time.\n',
                  ),
                  const TextSpan(
                    text: '• You can delete your own posts whenever you wish.\n',
                  ),
                  const TextSpan(
                    text: '• You have the right to request full account and data deletion through the settings menu.\n\n',
                  ),
                  _buildRichHeader(theme, '6. Contact Us (संपर्क करें)\n'),
                  const TextSpan(
                    text: 'If you have any questions or concerns about your privacy, please reach out to us at: life.jay.com@gmail.com\n',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  TextSpan _buildRichHeader(ThemeData theme, String text) {
    return TextSpan(
      text: text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        height: 2.5,
      ),
    );
  }
}
