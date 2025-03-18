import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // get instance of firebase auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  // get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // try sign user in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      // try sign user in
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await FacebookAuth.instance.logOut();
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception("Error during sign out: $e");
    }
  }

// sign in with google
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google sign-in cancelled by user.");
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Google sign-in failed.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // sign in with facebook
  Future<void> signInWithFacebook() async {
    try {
      // Đăng xuất phiên cũ để đảm bảo không dùng tài khoản trước đó
      await FacebookAuth.instance.logOut();

      // Gọi đăng nhập
      LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.dialogOnly,
      );

      // Nếu bấm Cancel, đăng xuất và thử lại
      while (result.status == LoginStatus.cancelled) {
        // Đăng xuất để xóa phiên hiện tại
        await FacebookAuth.instance.logOut();
        // Gọi lại dialog đăng nhập
        result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
          loginBehavior: LoginBehavior.dialogOnly,
        );
      }

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await _firebaseAuth.signInWithCredential(facebookCredential);
      } else {
        throw Exception("Facebook sign-in failed: ${result.message}");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Facebook sign-in failed.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
