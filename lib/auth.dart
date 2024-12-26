import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      if(googleAuth?.accessToken != null && googleAuth?.idToken != null){
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e){
      print(e.stackTrace.toString());
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}