import 'package:flutter/material.dart';

class CategoryTag extends StatelessWidget {
  final String category;
  final double fontSize;

  const CategoryTag({super.key, required this.category, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;

    // Use consistent theme-aware colors or standard category mapping
    switch (category.toLowerCase()) {
      case 'corruption':
        color = Colors.red;
        break;
      case 'road':
        color = Colors.orange;
        break;
      case 'ration':
        color = Colors.amber;
        break;
      case 'water':
        color = Colors.blue;
        break;
      case 'school':
        color = Colors.green;
        break;
      default:
        color = theme.colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
