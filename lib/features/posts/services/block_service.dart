import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



final blockServiceProvider = Provider<BlockService>((ref) => BlockService());

class BlockService {
  SupabaseClient get _supabase => Supabase.instance.client;
  static const String _blockBoxName = 'blocked_users';

  Future<void> init() async {
    await Hive.openBox<String>(_blockBoxName);
  }

  Future<void> blockUser(String blockedUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('user_blocks').insert({
        'blocker_id': user.id,
        'blocked_id': blockedUserId,
      });

      final box = Hive.box<String>(_blockBoxName);
      if (!box.values.contains(blockedUserId)) {
        await box.add(blockedUserId);
      }
    } catch (e) {
      if (e.toString().contains('23505')) {
        final box = Hive.box<String>(_blockBoxName);
        if (!box.values.contains(blockedUserId)) {
          await box.add(blockedUserId);
        }
      } else {
        rethrow;
      }
    }
  }

  List<String> getBlockedUserIds() {
    final box = Hive.box<String>(_blockBoxName);
    return box.values.toList();
  }

  Future<void> syncBlocks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('user_blocks')
          .select('blocked_id')
          .eq('blocker_id', user.id);

      final box = Hive.box<String>(_blockBoxName);
      await box.clear();
      final ids = (response as List).map((r) => r['blocked_id'] as String).toList();
      await box.addAll(ids);
    } catch (e) {
      // Sync failed, fallback to local cache
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('user_blocks')
        .delete()
        .eq('blocker_id', user.id)
        .eq('blocked_id', blockedUserId);

    final box = Hive.box<String>(_blockBoxName);
    final key = box.keys.firstWhere(
      (k) => box.get(k) == blockedUserId,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }
}
