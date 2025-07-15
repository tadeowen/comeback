<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

//our signing in formatt
  Future<User?> signInAnnonymously() async{
    try {
      UserCredential userCredential = await auth.signInAnnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in annonymously: $e');
      return null;
    }
  }

}

class UserCredential {
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

//our signing in formatt
  Future<User?> signInAnnonymously() async{
    try {
      UserCredential userCredential = await auth.signInAnnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in annonymously: $e');
      return null;
    }
  }

}

class UserCredential {
>>>>>>> 7e0f36a65e2080f289d0af718b5635cd54c3bc7c
}