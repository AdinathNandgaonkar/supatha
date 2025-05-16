// FIREBASE - Backend

import 'package:cloud_firestore/cloud_firestore.dart';
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
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) throw Exception("User data not found in database");

      return AppUser.fromJson({...doc.data()!, 'uid': uid});
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  //REGISTER: Email & Password
  @override
  Future<AppUser?> registerWithEmailPassword(
      String firstName, String lastName, String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final appUser = AppUser(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(appUser.toJson());

      return appUser;
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
    final displayName = firebaseUser.displayName;
    final parts = displayName?.split(' ');
    final firstName = parts!.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    //Logged in user exists
    return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        firstName: firstName,
        lastName: lastName);
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
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null;

      final gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final displayName = user.displayName ?? '';
        final parts = displayName.split(' ');
        final firstName = parts.isNotEmpty ? parts[0] : '';
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        final newUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          password: null,
          createdAt: DateTime.now(),
        );

        await docRef.set(newUser.toJson());
        return newUser;
      } else {
        return AppUser.fromJson({...doc.data()!, 'uid': user.uid});
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
