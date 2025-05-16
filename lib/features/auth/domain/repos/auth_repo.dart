// AUTH REPOSITORY - Outlines the possible auth operations for this app

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supatha_shuttles/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> registerWithEmailPassword(
      String firstName, String lastName, String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = cred.user;
      if (user == null) return null;

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(appUser.toJson());

      return appUser;
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }

  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = cred.user;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return AppUser.fromJson({...doc.data()!, 'uid': user.uid});
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendResetPasswordEmail(String email);
  Future<void> deleteAccount();
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
          await FirebaseAuth.instance.signInWithCredential(credential);
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

        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          password: null,
        );

        await docRef.set(appUser.toJson());
        return appUser;
      } else {
        final data = doc.data();
        return AppUser.fromJson({...data!, 'uid': user.uid});
      }
    } catch (e) {
      print("Google sign-in error: $e");
      return null;
    }
  }
}
