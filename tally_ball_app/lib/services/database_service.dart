import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update a user profile
  Future<void> createOrUpdateUserProfile({
    required String uid,
    required String email,
    String? name,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        // ── New account: create full document ──
        await userRef.set({
          'email': email,
          // Use provided name; fall back to the part before @ in the email
          'name': name ?? email.split('@').first,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'totalXP': 0,
          'gamesPlayed': 0,
          if (extraData != null) ...extraData,
        });
      } else {
        // ── Existing account: only overwrite fields we have new data for ──
        final Map<String, dynamic> updateData = {
          'email': email,
          'lastLogin': FieldValue.serverTimestamp(),
        };
        // Only update name when explicitly provided (Google login / profile setup)
        if (name != null) updateData['name'] = name;
        if (extraData != null) updateData.addAll(extraData);
        await userRef.update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user name
  Future<void> updateUserName({
    required String uid,
    required String newName,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': newName,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update profile image URL
  Future<void> updateProfileImage({
    required String uid,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Save a game session
  Future<void> saveGameSession({
    required String uid,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .add({
        ...sessionData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Also update total stats on the user document
      final userRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          final currentXP = snapshot.data()?['totalXP'] ?? 0;
          final currentGames = snapshot.data()?['gamesPlayed'] ?? 0;
          transaction.update(userRef, {
            'totalXP': currentXP + (sessionData['score'] ?? 0),
            'gamesPlayed': currentGames + 1,
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get real-time game sessions stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getGameSessionsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
