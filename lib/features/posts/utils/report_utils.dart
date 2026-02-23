import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/posts_provider.dart';

class ReportHelper {
  static final reasons = [
    {'en': 'Spam', 'hi': 'स्पैम'},
    {'en': 'Inappropriate Content', 'hi': 'अनुचित सामग्री'},
    {'en': 'Harassment', 'hi': 'उत्पीड़न'},
    {'en': 'False Information', 'hi': 'गलत जानकारी'},
    {'en': 'Hate Speech', 'hi': 'अभद्र भाषा'},
    {'en': 'Wrong Ward', 'hi': 'गलत वार्ड'},
    {'en': 'Other', 'hi': 'अन्य'},
  ];

  static void showReportSheet(
    BuildContext context,
    WidgetRef ref,
    String postId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'रिपोर्ट करने का कारण चुनें\nSelect Reason for Reporting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  final reason = reasons[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.report_problem_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(reason['hi']!),
                    subtitle: Text(reason['en']!),
                    onTap: () {
                      context.pop();
                      _submitReport(context, ref, postId, reason['en']!);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('CANCEL (रद्द करें)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _submitReport(
    BuildContext context,
    WidgetRef ref,
    String postId,
    String reason,
  ) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Processing report...')));
      }

      await ref.read(postServiceProvider).reportPost(postId);
      ref.invalidate(postsProvider); // Refresh feed

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            title: const Text('धन्यवाद (Thank You)'),
            content: const Text(
              'आपकी रिपोर्ट प्राप्त हो गई है। हम इसकी समीक्षा करेंगे।\n\nYour report has been submitted. We will review it shortly.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
