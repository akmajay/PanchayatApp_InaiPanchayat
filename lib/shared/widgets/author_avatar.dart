import 'package:flutter/material.dart';

class AuthorAvatar extends StatelessWidget {
  final String authorName;
  final bool isAnonymous;
  final double radius;

  const AuthorAvatar({
    super.key,
    required this.authorName,
    required this.isAnonymous,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isAnonymous) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.person_outline,
          size: radius * 1.2,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
