import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Singleton pattern for global access
  FirebaseService._privateConstructor();
  static final FirebaseService instance = FirebaseService._privateConstructor();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Sign in anonymously and create user profile if not exists
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      if (userCredential.user != null) {
        await createUserProfileIfNotExists(userCredential.user!);
      }
      return userCredential.user;
    } catch (e) {
      print('❌ Error signing in anonymously: $e');
      return null;
    }
  }

  /// Create Firestore user profile if not exists
  Future<void> createUserProfileIfNotExists(User user) async {
    try {
      final docRef = firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'name': 'Anonymous',
          'age': 0,
          'appointments': [],
          'photoUrl': null,
        });
        print('✅ Created new profile for UID: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error creating user profile: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return auth.currentUser;
  }

  /// Get Firestore user profile stream (live updates)
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(
      String uid) {
    return firestore.collection('users').doc(uid).snapshots();
  }

  /// Get user profile once (non-stream)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileOnce(
      String uid) async {
    return await firestore.collection('users').doc(uid).get();
  }

  /// Update user profile fields
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('❌ Error updating user profile: $e');
    }
  }

  /// Add new appointment using a transaction
  Future<void> addAppointment(
      String uid, Map<String, dynamic> appointment) async {
    final docRef = firestore.collection('users').doc(uid);
    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentAppointments =
            snapshot.get('appointments') as List<dynamic>? ?? [];
        final updatedAppointments = List<dynamic>.from(currentAppointments)
          ..add(appointment);
        transaction.update(docRef, {'appointments': updatedAppointments});
      });
    } catch (e) {
      print('❌ Failed to add appointment: $e');
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }
}
