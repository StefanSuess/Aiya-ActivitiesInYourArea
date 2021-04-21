import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  // stream for when authstate changes
  Stream<User> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // stream for when user profile changes
  Stream<User> get currentUserInformation => _firebaseAuth.userChanges();

  Future<String> getCurrentUserEmail() async {
    return _firebaseAuth.currentUser.email;
  }

  // GET UID
  Future<String> getCurrentUID() async {
    return _firebaseAuth.currentUser.uid;
  }

  Future setDisplayName(String displayName) async {
    await _firebaseAuth.currentUser.updateProfile(displayName: displayName);
  }

  Future setEmail(String eMail) async {
    await _firebaseAuth.currentUser.updateEmail(eMail);
  }

  Future deleteUser() async {
    try {
      await _firebaseAuth.currentUser.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  Future setPhotoURL(String photoURL, BuildContext context) async {
    await Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(context: context, photoURL: photoURL);
  }

  Future resetPassword() async {
    var email = _firebaseAuth.currentUser.email;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // firebase will automatically store user locally and the stream setup by auth_provider and auth_service automatically navigates the user to the explore tab if successfully logged in
  Future<String> loginViaEmail(
      {@required String email, @required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user';
      } else if (e.code == 'unknown') {
        return 'Fill in your email and password first';
      } else if (e.code == 'invalid-email') {
        return 'Invalid E-Mail';
      } else if (e.code == 'No user found for that email') {
        return 'No user found for that email';
      } else if (e.code == 'Wrong password provided for that user') {
        return 'Wrong password provided for that user';
      }
    }
    return ''; // return "nothing" as an error code if no error occurred
  }

  Future<String> registerWithEmail(
      {@required String email,
      @required String password,
      @required String displayName,
      @required BuildContext context}) async {
    // check if username is given
    if (displayName == null || displayName == '') {
      return 'Please enter your username first';
    }
    try {
      // register user
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) async {
        // TODO: set display name every time additional user data changes etc.
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(
                context: context,
                name: displayName,
                tagLine: 'Hi I\'m new here :)');
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid_email') {
        return 'EMail address not valid';
      } else if (e.code == 'unknown') {
        return 'Fill in your email and password first';
      } else {
        return e.message;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return '';
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // gets the current user profile when no UID is given, returns the userprofile identified with the UID otherwise
  Future<UserProfile> getUserProfile(
      {String UID, @required BuildContext context}) async {
    var uid;
    if (UID == null || UID == '') {
      uid = await getCurrentUID();
    } else {
      uid = UID;
    }
    var userProfile =
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .getAdditionalUserData(context: context, uid: uid);
    return userProfile;
  }

  Stream<UserProfile> getUserProfileAsStream(
      {String UID, @required BuildContext context}) async* {
    var uid;
    if (UID == null || UID == '') {
      uid = await getCurrentUID();
    } else {
      uid = UID;
    }
    var userProfile =
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .getAdditionalUserData(context: context, uid: uid);
    yield userProfile;
  }

  Future setInterests(
      {String age,
      List<String> interests,
      @required BuildContext context}) async {
    await Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(
            age: null, interests: interests, context: context);
  }

  Future<String> getAge(BuildContext context) async {
    var userProfile =
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .getAdditionalUserData(context: context);
    return userProfile.age;
  }
}
