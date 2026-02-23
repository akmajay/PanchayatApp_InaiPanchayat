import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/posts/utils/report_utils.dart';

class ReportButton extends ConsumerWidget {
  final String postId;
  final Color? color;
  final double? size;

  const ReportButton({super.key, required this.postId, this.color, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        Icons.report_problem_outlined,
        color: color ?? Colors.orange,
        size: size ?? 24,
      ),
      onPressed: () => ReportHelper.showReportSheet(context, ref, postId),
      tooltip: 'Report Post',
    );
  }
}
