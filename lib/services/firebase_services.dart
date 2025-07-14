import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Singleton pattern
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
          'religion': 'Unknown',
          'role': 'Guest',
          'createdAt': Timestamp.now(),
        });
        print('✅ Created new profile for UID: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error creating user profile: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() => auth.currentUser;

  /// Get Firestore user profile stream (real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String uid) {
    return firestore.collection('users').doc(uid).snapshots();
  }

  /// Get user profile once (non-stream)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileOnce(String uid) async {
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
  Future<void> addAppointment(String uid, Map<String, dynamic> appointment) async {
    final docRef = firestore.collection('users').doc(uid);
    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentAppointments = List<dynamic>.from(snapshot.get('appointments') ?? []);
        currentAppointments.add(appointment);
        transaction.update(docRef, {'appointments': currentAppointments});
      });
    } catch (e) {
      print('❌ Failed to add appointment: $e');
      rethrow;
    }
  }

  /// Delete appointment from user profile
  Future<void> deleteAppointment(String uid, Map<String, dynamic> appointment) async {
    final docRef = firestore.collection('users').doc(uid);
    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final appointments = List<dynamic>.from(snapshot.get('appointments') ?? []);
        appointments.removeWhere((a) =>
            Map<String, dynamic>.from(a).toString() == appointment.toString());
        transaction.update(docRef, {'appointments': appointments});
      });
    } catch (e) {
      print('❌ Failed to delete appointment: $e');
    }
  }

  /// Check if user is Admin
  Future<bool> isAdmin(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['role'] == 'Admin';
  }

  /// Get all users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final querySnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
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
