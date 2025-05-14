// FIREBASE - Backend

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supatha_shuttles/features/auth/domain/entities/app_user.dart';
import 'package:supatha_shuttles/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo implements AuthRepo {
  //Access to firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //LOGIN: Email & Password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //Attempt sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //Create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  //REGISTER: Email & Password
  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      //Attempt sign in
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      //create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);
      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  //DELETE ACCOUNT
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in..');
      await user.delete();
      await logout();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  //GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async {
    //Get cuurent logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    //No logged in user
    if (firebaseUser == null) return null;

    //Logged in user exists
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  //LOGOUT
  @override
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await firebaseAuth.signOut();

      // Sign out from Google (if signed in)
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();

        try {
          await googleSignIn
              .disconnect(); // Attempt but don't fail if it errors
        } catch (e) {
          print('Non-fatal disconnect error: $e');
        }
      }
    } catch (e) {
      print('Logout error: $e');
      rethrow; // or handle gracefully in your Cubit
    }
  }

  //RESET PASSWORD
  @override
  Future<String> sendResetPasswordEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox";
    } catch (e) {
      throw Exception("An error has occured: $e");
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      //begin interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      //user cancelled sign in
      if (gUser == null) return null;

      //obtain auth details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      //create credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      //sign in with credentials
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      //firebase user
      final firebaseUser = userCredential.user;

      //user cancelled sign in process
      if (firebaseUser == null) return null;

      AppUser appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      return appUser;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
}
