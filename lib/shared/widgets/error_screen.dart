import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// User-friendly screen displayed when a critical error occurs
class AppErrorScreen extends StatelessWidget {
  final FlutterErrorDetails? details;

  const AppErrorScreen({super.key, this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'क्षमा करें, कुछ गलत हो गया', // "Sorry, something went wrong"
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'कृपया ऐप को फिर से खोलें या बाद में प्रयास करें।', // "Please reopen the app or try again later."
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Simply refresh/pop or let user decide
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ठीक है', // "Okay"
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              if (details != null) ...[
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text(
                    'Error Details (Admin)',
                    style: TextStyle(fontSize: 12),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        details!.exception.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
