import '../../../core/supabase_client.dart';

/// Profile Service
/// Handles profile CRUD operations with Supabase
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  /// Get current user's profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      return await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      // debugPrint removed
      return null;
    }
  }

  /// Update profile with phone and ward number
  Future<bool> updateProfile({
    required String phone,
    required int wardNo,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await supabase
          .from('profiles')
          .update({'phone': phone, 'ward_no': wardNo})
          .eq('id', user.id);

      return true;
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Check if user has completed their profile
  /// Returns true if both phone AND ward_no are set
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return false;

      final phone = profile['phone'] as String?;
      final wardNo = profile['ward_no'] as int?;

      return phone != null && phone.isNotEmpty && wardNo != null;
    } catch (e) {
      // debugPrint removed
      return false;
    }
  }

  /// Update full name
  Future<bool> updateFullName(String fullName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await supabase
          .from('profiles')
          .update({'full_name': fullName})
          .eq('id', user.id);
      return true;
    } catch (e) {
      // debugPrint removed
      return false;
    }
  }

  /// Delete account and all associated data
  Future<void> requestAccountDeletion() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Call edge function to handle cascading deletion (GDPR)
      // Added 15s timeout as per requirements
      await supabase.functions
          .invoke('delete-user-data')
          .timeout(const Duration(seconds: 15));

      // Sign out locally ONLY after success
      await supabase.auth.signOut();
    } catch (e) {
      // Throw a user-friendly error in Hindi as per requirement
      throw Exception(
        'सर्वर से कनेक्ट नहीं हो सका। कृपया बाद में प्रयास करें। (Could not connect to server. Please try again later.)',
      );
    }
  }
}
