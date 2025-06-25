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
}