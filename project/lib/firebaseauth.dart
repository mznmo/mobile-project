import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthClass{
  
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future <User?> signUpWithEmailAndPasswor(String email, String password) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;

  }

  Future <User?> signInWithEmailAndPasswor(String email, String password) async {

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occured");
    }
    return null;

  }
}