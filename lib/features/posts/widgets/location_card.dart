import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post_model.dart';

/// A card to display the GPS location of a post and open it in Google Maps
class LocationCard extends StatelessWidget {
  final Post post;

  const LocationCard({super.key, required this.post});

  Future<void> _openInMaps() async {
    if (post.latitude == null || post.longitude == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${post.latitude},${post.longitude}',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      // debugPrint removed
    }
  }

  @override
  Widget build(BuildContext context) {
    if (post.latitude == null || post.longitude == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'घटना स्थल (Incident Location)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ward ${post.wardNo ?? "---"} | Coords: ${post.latitude!.toStringAsFixed(6)}, ${post.longitude!.toStringAsFixed(6)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.map_outlined),
                label: const Text('VIEW ON GOOGLE MAPS (मैप पर देखें)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
