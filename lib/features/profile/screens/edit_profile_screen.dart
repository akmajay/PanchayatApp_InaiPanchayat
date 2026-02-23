import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  int? _selectedWard;
  bool _initialized = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeData(Map<String, dynamic> profile) {
    if (!_initialized) {
      _phoneController.text = profile['phone']?.toString() ?? '';
      _selectedWard = profile['ward_no'] as int?;
      _initialized = true;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ward number')),
      );
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the Terms of Service')),
      );
      return;
    }

    final success = await ref
        .read(profileUpdateProvider.notifier)
        .updateProfile(
          phone: _phoneController.text.trim(),
          wardNo: _selectedWard!,
        );

    if (success && mounted) {
      ref.invalidate(currentProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully! (प्रोफ़ाइल अपडेट हो गई!)',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final updateState = ref.watch(profileUpdateProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile (प्रोफ़ाइल बदलें)')),
      body: profileAsync.when(
        data: (profile) {
          if (profile != null) _initializeData(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Read-only info from Google
                  _buildReadOnlyField(
                    label: 'Full Name (पूरा नाम)',
                    value:
                        profile?['full_name'] ??
                        user?.email?.split('@').first ??
                        'User',
                    icon: Icons.person_outline,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    label: 'Email Address (ईमेल पता)',
                    value: user?.email ?? '',
                    icon: Icons.email_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Editable Phone
                  Text(
                    'Phone Number (फ़ोन नंबर)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter 10-digit phone number',
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length != 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Editable Ward
                  Text(
                    'Ward Number (वार्ड संख्या)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedWard,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: List.generate(17, (index) => index + 1)
                        .map(
                          (w) => DropdownMenuItem(
                            value: w,
                            child: Text('Ward $w (वार्ड $w)'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedWard = val),
                    hint: const Text('Select your ward'),
                  ),

                  // EULA Checkbox
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    title: const Text(
                      'I agree to the Terms of Service and will not post objectionable content.',
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: const Text(
                      'मैं नियमों से सहमत हूँ और आपत्तिजनक सामग्री पोस्ट नहीं करूँगा।',
                      style: TextStyle(fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 32),

                  if (updateState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        updateState.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton(
                    onPressed: updateState.isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: updateState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('SAVE CHANGES (बदलाव सुरक्षित करें)'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
