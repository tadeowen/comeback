import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // ✅ Singleton pattern for global access
  FirebaseService._privateConstructor();
  static final FirebaseService instance = FirebaseService._privateConstructor();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ✅ Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      await createUserProfileIfNotExists(userCredential.user!);
      return userCredential.user;
    } catch (e) {
      print('❌ Error signing in anonymously: $e');
      return null;
    }
  }

  /// ✅ Create Firestore user profile if not exists
  Future<void> createUserProfileIfNotExists(User user) async {
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
  }

  /// ✅ Get current user
  User? getCurrentUser() {
    return auth.currentUser;
  }

  /// ✅ Get Firestore user profile stream (live updates)
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return firestore.collection('users').doc(uid).snapshots();
  }

  /// ✅ Update user profile fields
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(uid).update(data);
  }

  /// ✅ Add new appointment
  Future<void> addAppointment(
      String uid, Map<String, dynamic> appointment) async {
    final docRef = firestore.collection('users').doc(uid);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentAppointments =
          snapshot['appointments'] as List<dynamic>? ?? [];
      final updatedAppointments = List<dynamic>.from(currentAppointments)
        ..add(appointment);
      transaction.update(docRef, {'appointments': updatedAppointments});
    });
  }

  /// ✅ Sign out user
  Future<void> signOut() async {
    await auth.signOut();
  }
}
