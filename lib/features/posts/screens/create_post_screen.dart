import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/post_model.dart';
import '../providers/posts_provider.dart';
import '../widgets/media_selector.dart';

/// Screen to create a new grievance/post
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  String _selectedCategory = 'other';
  bool _isAnonymous = false;
  XFile? _mediaFile;
  String _mediaType = 'text';
  bool _isSubmitting = false;

  bool _shareLocation = false;
  Position? _currentPosition;
  bool _isLocationLoading = false;
  String? _locationError;

  final List<String> _categories = [
    'corruption',
    'road',
    'ration',
    'water',
    'school',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    // Do not fetch location automatically - respect privacy toggle
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'GPS सेवा बंद है (Location disabled)');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(
            () => _locationError =
                'लोकेशन की अनुमति नहीं मिली (Permission denied)',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
          () => _locationError =
              'अनुमति स्थायी रूप से बंद है (Permission denied forever)',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'लोकेशन लाने में विफल (Fetch failed)';
        _isLocationLoading = false;
      });
      // debugPrint removed
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Location check only if sharing is enabled
    if (_shareLocation && _currentPosition == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('लोकेशन नहीं मिली! (No Location)'),
          content: const Text(
            'शिकायत की सच्चाई के लिए लोकेशन जरूरी है। क्या आप बिना लोकेशन के शिकायत दर्ज करना चाहते हैं?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('नहीं (No)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('हाँ (Yes)'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final profile = ref.read(currentProfileProvider).asData?.value;

      if (user == null || profile == null) {
        throw Exception('User details not found');
      }

      // 2. Prepare Post object
      final post = Post(
        id: const Uuid().v4(),
        userId: user.id,
        content: _contentController.text.trim(),
        mediaType: _mediaType,
        mediaUrl: null, // Initial URL is null, PostService handles upload
        category: _selectedCategory,
        isAnonymous: _isAnonymous,
        wardNo: profile['ward_no'] as int?,
        latitude: _shareLocation ? _currentPosition?.latitude : null,
        longitude: _shareLocation ? _currentPosition?.longitude : null,
        reportCount: 0,
        isHidden: false,
        createdAt: DateTime.now(),
      );

      // 3. Create Post
      final postService = ref.read(postServiceProvider);
      await postService.createPost(post, mediaFile: _mediaFile);

      if (!mounted) return;

      // 4. Success feedback and pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('आपका पोस्ट सफलतापूर्वक जुड़ गया है! (Post Created)'),
        ),
      );

      // Refresh feed
      ref.invalidate(postsProvider);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Grievance (शिकायत जोड़ें)')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category Selection
                    Text(
                      'Category (श्रेणी)',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((cat) {
                        return ChoiceChip(
                          label: Text(cat.toUpperCase()),
                          selected: _selectedCategory == cat,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Describe the issue (विवरण लिखें)',
                        hintText: 'Minimum 10 characters...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return 'विवरण कम से कम 10 अक्षरों का होना चाहिए (Min 10 chars)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Location Toggle
                    SwitchListTile(
                      title: const Text(
                        'स्थान साझा करें (Share Location)',
                      ),
                      subtitle: const Text(
                        'Coordinates help verify grievance legitimacy',
                      ),
                      value: _shareLocation,
                      onChanged: (val) {
                        setState(() => _shareLocation = val);
                        if (val && _currentPosition == null) {
                          _fetchLocation();
                        }
                      },
                      secondary: Icon(
                        Icons.location_on_outlined,
                        color: _shareLocation ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Anonymous Toggle
                    SwitchListTile(
                      title: const Text(
                        'Post Anonymously (गुप्त रूप से पोस्ट करें)',
                      ),
                      subtitle: const Text(
                        'Your name will not be shared publicly',
                      ),
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                      secondary: Icon(
                        Icons.visibility_off_outlined,
                        color: _isAnonymous ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Media Selector
                    MediaSelector(
                      onMediaSelected: (file, type) {
                        setState(() {
                          _mediaFile = file;
                          _mediaType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Status UI (Only show if location is being shared)
                    if (_shareLocation) ...[
                      _LocationStatus(
                        position: _currentPosition,
                        isLoading: _isLocationLoading,
                        error: _locationError,
                        onRetry: _fetchLocation,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text(
                        'SUBMIT GRIEVANCE (शिकायत भेजें)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  final Position? position;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _LocationStatus({
    required this.position,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: position != null
            ? Colors.green.shade50
            : (error != null ? Colors.red.shade50 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: position != null
              ? Colors.green.shade200
              : (error != null ? Colors.red.shade200 : Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(
            position != null
                ? Icons.location_on
                : (error != null
                      ? Icons.location_off
                      : Icons.location_searching),
            color: position != null
                ? Colors.green
                : (error != null ? Colors.red : Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position != null
                      ? '📍 स्थान जुड़ गया है (Location Attached)'
                      : (error ??
                            (isLoading
                                ? 'लोकेशन खोजी जा रही है...'
                                : 'लोकेशन की प्रतीक्षा...')),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: position != null
                        ? Colors.green.shade800
                        : (error != null
                              ? Colors.red.shade800
                              : Colors.grey.shade700),
                  ),
                ),
                if (position != null)
                  Text(
                    'Coords: ${position!.latitude.toStringAsFixed(4)}, ${position!.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(
                position != null ? Icons.refresh : Icons.my_location,
                size: 20,
              ),
              onPressed: onRetry,
              tooltip: 'अपडेट करें (Update Location)',
            ),
        ],
      ),
    );
  }
}
