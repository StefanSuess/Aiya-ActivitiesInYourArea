import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    var userCredential;
    // two different sign in methods for web and native
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      //googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
      // Once signed in, return the UserCredential
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }

    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(
            context: context,
            name: userCredential.user.displayName,
            photoURL: userCredential.user.photoURL,
            phoneNumber: userCredential.user.phoneNumber,
            uid: userCredential.user.uid);
  }

  Future<List<UserInfo>> getAuthProvider() async {
    return _firebaseAuth.currentUser.providerData;
  }

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

  Future resetPasswordLoginScreen(context) async {
    var email = '';
    Widget okButton = GFButton(
      text: 'Reset Password',
      color: Theme.of(context).accentColor,
      onPressed: () async {
        await _firebaseAuth.sendPasswordResetEmail(email: email).then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('An email was sent to $email ${Emojis.eMail}'),
                  action: SnackBarAction(
                    onPressed: () =>
                        ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                    label: 'OK',
                  ),
                )));
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget abortButton = GFButton(
      text: 'ABORT',
      type: GFButtonType.outline,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget emailTextField = TextField(
      obscureText: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Your Email',
      ),
      onChanged: (value) {
        email = value;
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Password Reset"),
      content: emailTextField,
      actions: [okButton, abortButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
