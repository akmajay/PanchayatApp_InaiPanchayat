import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

/// Service to handle Supabase Storage operations
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Upload a file to a specific bucket
  /// [path] should follow the pattern: 'userId/filename.ext'
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file, // Can be File or XFile
  }) async {
    try {
      final dynamic fileToUpload = file is File ? file : File(file.path);

      await supabase.storage
          .from(bucket)
          .upload(
            path,
            fileToUpload,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL
      final String publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Delete a file from a bucket
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }
}
