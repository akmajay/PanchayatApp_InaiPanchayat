import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// Widget for selecting and previewing media (image/video)
class MediaSelector extends StatefulWidget {
  final Function(XFile? file, String mediaType) onMediaSelected;

  const MediaSelector({super.key, required this.onMediaSelected});

  @override
  State<MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<MediaSelector> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  String _mediaType = 'text';
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // Compress image
      final compressedFile = await _compressImage(image);
      setState(() {
        _selectedFile = compressedFile;
        _mediaType = 'image';
        _videoController?.dispose();
        _videoController = null;
      });
      widget.onMediaSelected(_selectedFile, _mediaType);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 10),
    );

    if (video != null) {
      // Basic check for duration (though maxDuration helps)
      setState(() {
        _selectedFile = video;
        _mediaType = 'video_10s';
        _videoController = VideoPlayerController.file(File(video.path))
          ..initialize().then((_) {
            setState(() {});
          });
      });
      widget.onMediaSelected(_selectedFile, _mediaType);
    }
  }

  Future<XFile?> _compressImage(XFile file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      format: CompressFormat.webp,
    );

    return result != null ? XFile(result.path) : file;
  }

  void _clearMedia() {
    setState(() {
      _selectedFile = null;
      _mediaType = 'text';
      _videoController?.dispose();
      _videoController = null;
    });
    widget.onMediaSelected(null, 'text');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (_selectedFile != null) ...[
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: _mediaType == 'image'
                    ? Image.file(File(_selectedFile!.path), fit: BoxFit.cover)
                    : (_videoController?.value.isInitialized ?? false)
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clearMedia,
                  ),
                ),
              ),
              if (_mediaType == 'video_10s' && _videoController != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_videoController!.value.duration.inSeconds}s Video',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MediaButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            _MediaButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            _MediaButton(
              icon: Icons.videocam,
              label: 'Video (10s)',
              onTap: _pickVideo,
            ),
            _MediaButton(
              icon: Icons.link,
              label: 'Link',
              onTap: () {
                // User-selected URL functionality
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
