import 'package:flutter/material.dart';

/// Mandatory disclaimer to prevent suspension for "Government Impersonation"
class GovernmentDisclaimer extends StatelessWidget {
  final bool compact;

  const GovernmentDisclaimer({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: compact ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'अस्वीकरण (Disclaimer)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'यह ऐप सरकारी नहीं है और किसी सरकारी निकाय से संबंधित नहीं है। यह एक स्वतंत्र सामुदायिक मंच है। (This is an independent platform and NOT affiliated with any government body.)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All data is user-generated. We do not represent any government entity.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
