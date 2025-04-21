import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestoreService.saveUserProfile(userCredential.user!.uid, {
        'loginMethod': 'email',
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password, String name, String phone) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestoreService.saveUserProfile(userCredential.user!.uid, {
        'name': name,
        'email': email,
        'phone': phone,
        'loginMethod': 'email',
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await FacebookAuth.instance.logOut();
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception("Error during sign out: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print("Starting Google sign-in...");
      await _googleSignIn.signOut();
      print("Google sign-out completed.");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google sign-in cancelled by user.");
        throw Exception("Google sign-in cancelled by user.");
      }
      print("Google user: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          "Google auth: accessToken=${googleAuth.accessToken}, idToken=${googleAuth.idToken}");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print("Firebase sign-in successful: ${userCredential.user?.email}");
      await _firestoreService.saveUserProfile(userCredential.user!.uid, {
        'name': googleUser.displayName,
        'email': googleUser.email,
        'phone': '',
        'loginMethod': 'google',
      });
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      throw Exception(e.message ?? "Google sign-in failed.");
    } catch (e) {
      print("General exception in Google sign-in: $e");
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      print("Starting Facebook sign-in...");
      await FacebookAuth.instance.logOut();
      print("Facebook sign-out completed.");
      LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.webOnly,
      );
      print(
          "Facebook login result: ${result.status}, message: ${result.message}");
      if (result.status == LoginStatus.cancelled) {
        print("Facebook sign-in cancelled by user.");
        throw Exception("Facebook sign-in cancelled by user.");
      }
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(facebookCredential);
        print("Firebase sign-in successful: ${userCredential.user?.email}");
        final userData = await FacebookAuth.instance.getUserData();
        print("Facebook user data: $userData");
        await _firestoreService.saveUserProfile(userCredential.user!.uid, {
          'name': userData['name'],
          'email': userData['email'],
          'phone': '',
          'loginMethod': 'facebook',
        });
      } else {
        print("Facebook sign-in failed: ${result.message}");
        throw Exception("Facebook sign-in failed: ${result.message}");
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      throw Exception(e.message ?? "Facebook sign-in failed.");
    } catch (e) {
      print("General exception in Facebook sign-in: $e");
      throw Exception("Facebook sign-in failed: $e");
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final profile = await _firestoreService.getUserProfile(user.uid);
        if (profile != null) {
          return profile;
        } else {
          throw Exception('Profile not found');
        }
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // fill in the old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // update new pasword
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  
}


