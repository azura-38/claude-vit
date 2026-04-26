import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard_user.dart';

final leaderboardRepositoryProvider = Provider((ref) => LeaderboardRepository());

class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionPath = 'leaderboard';

  Future<void> syncXP(String uid, int xp) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).set({
        'xp': xp,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Sliently fail if no internet
    }
  }

  Future<List<LeaderboardUser>> getTopUsers({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('xp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardUser.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
