import 'dart:async';
import 'dart:io';

import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/logo_widget.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/CludeStore/cloudstore_provider.dart';
import 'package:Aiya/services/activities/firestore_provider.dart';
import 'package:Aiya/services/user/auth_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfileWidget> {
  List<String> interestsList = [];
  List<String> contactOptionsList = [];
  bool _selected = true;

  // TODO: clean this up --> refactor to streambuilder

  // VARIABLES
  var newEmail = '';
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  String photoURL = '';
  final picker = ImagePicker();

  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final interestsController = TextEditingController();

  // FUNCTIONS

  void logOut() async {
    await FirebaseAuth.instance
        .signOut()
        .then((value) => null)
        .catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${onError.toString()} ${Emojis.cryingFace}'),
          action: SnackBarAction(
            onPressed: () =>
                ScaffoldMessenger.of(context).removeCurrentSnackBar(),
            label: 'OK',
          )));
    });
  }

  void deleteUser() async {
    // because deleting is a security-sensitive operation authentication is required
    showReauthenticationDialog(context);
    Provider.of<AuthProvider>(context).auth.deleteUser();
  }

  Future<void> updateUserProfile() async {
    //Potential race condition here because text is reset and controller value could thus be changed
    var userName = userNameController.text;
    newEmail = emailController.text;
    var age = ageController.text;
    var mobileNumber = phoneNumberController.text;
    try {
      if (userName.isNotEmpty) {
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(context: context, name: userName);
      }

      if (age.isNotEmpty) {
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(context: context, age: age);
      }

      if (mobileNumber.isNotEmpty) {
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(context: context, phoneNumber: mobileNumber);
      }

      // get current email
      var currentEmail = await Provider.of<AuthProvider>(context, listen: false)
          .auth
          .getCurrentUserEmail();
      // check if a new email was entered
      if (currentEmail != newEmail) {
        showReauthenticationDialog(context);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e ${Emojis.cryingFace}'),
          action: SnackBarAction(
            onPressed: () =>
                ScaffoldMessenger.of(context).removeCurrentSnackBar(),
            label: 'OK',
          )));
    }
  }

  void reauthenticateUser(String email, String password) async {
// Create a credential
    EmailAuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
// Reauthenticate
    await FirebaseAuth.instance.currentUser
        .reauthenticateWithCredential(credential);
  }

  Future<void> showReauthenticationDialog(BuildContext context) async {
    var password = '';
    var currentEmail = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUserEmail();
    Widget okButton = GFButton(
      text: 'DELETE ACCOUNT',
      color: Theme.of(context).errorColor,
      onPressed: () {
        reauthenticateUser(currentEmail, password);
        Provider.of<AuthProvider>(context, listen: false)
            .auth
            .setEmail(newEmail);
        //TODO: show error message if password is wrong
        Navigator.of(context, rootNavigator: true).pop();
      },
      fullWidthButton: true,
    );
    Widget abortButton = GFButton(
      text: 'ABORT',
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      fullWidthButton: true,
    );
    Widget passwordTextField = TextField(
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Current Password',
      ),
      onChanged: (value) {
        password = value;
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Authentication required"),
      content: passwordTextField,
      actions: [okButton, abortButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getImage({@required String option}) async {
    switch (option) {
      case 'Camera':
        {
          if (kIsWeb) {
            // check if app is running in an web browser
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Camera is not supported on the web :('),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ));
          } else {
            var pickedFile = await picker.getImage(source: ImageSource.camera);
            cropImage(pickedFile: pickedFile);
          }
        }
        break;
      case 'Gallery':
        {
          if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gallery is currently not supported on the web :('),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ));
          } else {
            var result =
                await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null) {
              var file = File(result.files.single.path);
              if (kIsWeb) {
                await Provider.of<CloudStoreProvider>(context, listen: false)
                    .storage
                    .uploadProfilePicture(file,
                        context); //upload the file instantly when on web because cropping is not really supported
              } else {
                // crop the file when not on web
                cropImage(file: file);
              }
              ;
            }
          }
          break;
        }
    }
  }

  void cropImage({PickedFile pickedFile, File file}) async {
    var fileToCrop;
    switch (file) {
      case null:
        {
          fileToCrop = pickedFile;
        }
        break;
      default:
        {
          fileToCrop = file;
        }
        break;
    }
    var croppedFile = await ImageCropper.cropImage(
        sourcePath: fileToCrop.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    await Provider.of<CloudStoreProvider>(context, listen: false)
        .storage
        .uploadProfilePicture(croppedFile, context);
  }

  Widget _getEditIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _status = false;
        });
      },
      child: CircleAvatar(
        backgroundColor: Theme.of(context).accentColor,
        radius: 20.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }

  Widget _getSaveAbortIcons() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 20.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                updateUserProfile();
                _status = true;
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 20.0,
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              // show current user details and remove canceled ones
              _status = true;
            });
          },
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 20.0,
            child: Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _logOutButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GFButton(
          text: 'LogOut',
          type: GFButtonType.outline,
          onPressed: () => logOut(),
        ),
      ),
    );
  }

  Widget _deleteUserButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GFButton(
          text: 'Delete Account',
          color: Theme.of(context).errorColor,
          type: GFButtonType.outline,
          onPressed: () => deleteUser(),
        ),
      ),
    );
  }

  Widget _aboutButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GFButton(
          text: 'About',
          type: GFButtonType.outline,
          onPressed: () => showAboutDialog(
              context: context,
              applicationLegalese:
                  '© 2021 Stefan Suess.  All rights reserved. ',
              applicationName: 'Aiya',
              applicationVersion: 'Version: 1.0',
              applicationIcon: Logo()),
        ),
      ),
    );
  }

  Widget _resetPasswordButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GFButton(
          text: 'Reset Password',
          type: GFButtonType.outline,
          onPressed: () => _showPasswordResetDialog(),
        ),
      ),
    );
  }

  void _showPasswordResetDialog() {
    Widget okButton = GFButton(
      text: 'OK',
      color: Theme.of(context).accentColor,
      onPressed: () {
        Provider.of<AuthProvider>(context, listen: false)
            .auth
            .resetPassword()
            .then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Password reset email was sent :)'),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () =>
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                      ),
                    )));
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget abortButton = GFButton(
      text: 'Abort',
      color: Theme.of(context).errorColor,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Password Reset"),
      content: Text('You will receive an email to reset your password'),
      actions: [okButton, abortButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    emailController.dispose();
    userNameController.dispose();
    ageController.dispose();
    phoneNumberController.dispose();
    interestsController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: ListView(
          children: <Widget>[
            Stack(
              children: [
                Column(
                  children: <Widget>[
                    Container(
                      height: 250.0,
                      child: Column(
                        children: <Widget>[AvatarPicture()],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 0.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          GFTypography(
                                            text: 'Personal Information',
                                            type: GFTypographyType.typo2,
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        _status
                                            ? _getEditIcon()
                                            : _getSaveAbortIcons(),
                                      ],
                                    )
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Expanded(
                                      child: GFTypography(
                                        text: 'Name',
                                        type: GFTypographyType.typo4,
                                        showDivider: false,
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: GFTypography(
                                        text: 'Age',
                                        type: GFTypographyType.typo4,
                                        showDivider: false,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    NameWidget(),
                                    Container(
                                      width: 16,
                                    ),
                                    AgeWidget(),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    GFTypography(
                                      text: 'E-Mail',
                                      type: GFTypographyType.typo4,
                                      showDivider: false,
                                    ),
                                  ],
                                )),
                            EmailWidget(),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Expanded(
                                          child: GFTypography(
                                            text: 'Mobile Number',
                                            type: GFTypographyType.typo4,
                                            showDivider: false,
                                          ),
                                        ),
                                        Container(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: GFTypography(
                                            text: 'Contact Options',
                                            type: GFTypographyType.typo4,
                                            showDivider: false,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    phoneWidget(),
                                    Container(
                                      width: 16,
                                    ),
                                    contactOptions(),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Container(
                                  child: GFTypography(
                                    text: 'Interests',
                                    type: GFTypographyType.typo4,
                                    showDivider: false,
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Your Interests',
                                        ),
                                        autocorrect: true,
                                        enableSuggestions: true,
                                        enabled: !_status,
                                        controller: interestsController,
                                      ),
                                    ),
                                    _status
                                        ? IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              FontAwesomeIcons.plusCircle,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              addInterest();
                                              interestsController.clear();
                                            },
                                            icon: Icon(
                                              FontAwesomeIcons.plusCircle,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          )
                                  ],
                                )),
                            interestsChips(),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _logOutButton(),
                                _resetPasswordButton(),
                                _aboutButton(),
                              ],
                            ),
                            _deleteUserButton()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                BackButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void addInterest() {
    // check if value already exists, if yes do not add value
    interestsList.contains(interestsController.text)
        ? null
        : interestsList.add(interestsController.text);
    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(context: context, interests: interestsList);
  }

  void removeInterest(String interest) {
    interestsList.removeWhere((element) => element == interest);
    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(context: context, interests: interestsList);
  }

  Widget interestsChips() {
    return StreamBuilder(
        stream: Provider.of<FirestoreProvider>(context)
            .instance
            .getAdditionalUserDataAsStream(context: context),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          if (snapshot.hasError) return Container();
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(),
              );
            case ConnectionState.waiting:

            case ConnectionState.active:
            case ConnectionState.done:
              // add current interests to list to avoid overriding the old interests with the new ones
              interestsList = List.from(snapshot.data?.interests ?? []);
              contactOptionsList =
                  List.from(snapshot.data?.contactOptions ?? []);
              return Padding(
                // TODO: implement interests
                padding: const EdgeInsets.only(left: 32, right: 32, top: 8),
                child: !_status
                    ? Wrap(
                        spacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [...snapshot.data.interests]
                            .map((e) => InputChip(
                                  label: Text(e),
                                  deleteIcon: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onDeleted: () => removeInterest(e),
                                ))
                            .toList(),
                      )
                    : Wrap(
                        spacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [...snapshot.data.interests]
                            .map((e) => InputChip(
                                  label: Text(e),
                                ))
                            .toList(),
                      ),
              );
          }
          return null; // unreachable}, ),
        });
  }

  Widget AvatarPicture() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Stack(fit: StackFit.loose, children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 200.0,
                height: 200.0,
                child: StreamBuilder(
                    stream: Provider.of<FirestoreProvider>(context)
                        .instance
                        .getAdditionalUserDataAsStream(context: context),
                    builder: (BuildContext context,
                        AsyncSnapshot<UserProfile> snapshot) {
                      if (snapshot.hasError) throw (snapshot.error);
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          return ProfilePictureLoader(
                            imageURL: snapshot?.data?.photoURL ?? '',
                          );
                      }
                      return null; // unreachable}, ),
                    })),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(top: 140.0, right: 140.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton(
                  items: <String>['Gallery', 'Camera']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    radius: 35.0,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (value) {
                    getImage(option: value);
                  },
                ),
              ],
            )),
      ]),
    );
  }

  Widget phoneWidget() {
    return Flexible(
        child: StreamBuilder(
            stream: Provider.of<FirestoreProvider>(context)
                .instance
                .getAdditionalUserDataAsStream(context: context),
            builder:
                (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
              if (snapshot.hasError) throw (snapshot.error);
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  phoneNumberController.text =
                      snapshot?.data?.phoneNumber ??= '';
                  return TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Mobile Number',
                    ),
                    enabled: !_status,
                    autofocus: !_status,
                    controller: phoneNumberController,
                  );
              }
              return null; // unreachable}, ),
            }));
  }

  // TODO: avoid "blinking" effect
  Widget contactOptions() {
    return Flexible(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [whatsAppContact(), smsContact()],
    ));
  }

  Widget whatsAppContact() {
    return StreamBuilder(
        stream: Provider.of<FirestoreProvider>(context)
            .instance
            .getAdditionalUserDataAsStream(context: context),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          if (snapshot.hasError) throw (snapshot.error);
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data != null) {
                return snapshot.data.contactOptions.contains('WhatsApp')
                    ? GFIconButton(
                        onPressed: // get allowed contact options
                            () {
                          removeContactOption('WhatsApp');
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                        ),
                        type: GFButtonType.transparent,
                      )
                    : GFIconButton(
                        onPressed: () {
                          addContactOption('WhatsApp');
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.whatsapp,
                        ),
                        color: Colors.grey,
                        type: GFButtonType.transparent,
                      );
              }
          }
          return Container(); // unreachable}, ),
        });
  }

  Widget smsContact() {
    return StreamBuilder(
        stream: Provider.of<FirestoreProvider>(context)
            .instance
            .getAdditionalUserDataAsStream(context: context),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          if (snapshot.hasError) throw (snapshot.error);
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data != null) {
                return snapshot.data.contactOptions.contains('SMS')
                    ? GFIconButton(
                        onPressed: // get allowed contact options
                            () {
                          removeContactOption('SMS');
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.sms,
                        ),
                        type: GFButtonType.transparent,
                      )
                    : GFIconButton(
                        onPressed: () {
                          addContactOption('SMS');
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.sms,
                        ),
                        color: Colors.grey,
                        type: GFButtonType.transparent,
                      );
              }
          }
          return Container(); // unreachable}, ),
        });
  }

  void addContactOption(String contactOption) {
    contactOptionsList.contains(contactOption)
        ? null
        : contactOptionsList.add(contactOption);
    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(
            context: context, contactOptions: contactOptionsList);
  }

  void removeContactOption(String contactOption) {
    contactOptionsList.removeWhere((element) => element == contactOption);
    Provider.of<FirestoreProvider>(context, listen: false)
        .instance
        .setAdditionalUserData(
            context: context, contactOptions: contactOptionsList);
  }

  Widget NameWidget() {
    return Flexible(
        child: StreamBuilder(
            stream: Provider.of<FirestoreProvider>(context)
                .instance
                .getAdditionalUserDataAsStream(context: context),
            builder:
                (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
              if (snapshot.hasError) throw (snapshot.error);
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  userNameController.text = snapshot?.data?.name;
                  return TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Name',
                    ),
                    enabled: !_status,
                    autofocus: !_status,
                    controller: userNameController,
                  );
              }
              return null; // unreachable}, ),
            }));
  }

  Widget AgeWidget() {
    return Flexible(
        child: StreamBuilder(
            stream: Provider.of<FirestoreProvider>(context)
                .instance
                .getAdditionalUserDataAsStream(context: context),
            builder:
                (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
              if (snapshot.hasError) throw (snapshot.error);
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  ageController.text = snapshot?.data?.age ??= '';

                  return TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Age',
                    ),
                    enabled: !_status,
                    autofocus: !_status,
                    controller: ageController,
                  );
              }
              return null; // unreachable}, ),
            }));
  }

  Widget EmailWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: StreamBuilder(
                  stream: Provider.of<AuthProvider>(context)
                      .auth
                      .currentUserInformation,
                  builder:
                      (BuildContext context, AsyncSnapshot<User> snapshot) {
                    if (snapshot.hasError) throw (snapshot.error);
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                      case ConnectionState.done:
                        emailController.text = snapshot?.data?.email ?? '';
                        return TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Email (placeholder)',
                          ),
                          enabled: !_status,
                          controller: emailController,
                        );
                    }
                    return null; // unreachable}, ),
                  }),
            )
          ],
        ));
  }
}
