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
  List<String> eventList = [
    'Play',
    'Football',
    'Riding',
    'Flutter',
    'Books',
    'Sport',
    'Climbing'
  ];
  bool _selected = true;

  // TODO: clean this up --> refactor to streambuilder

  // VARIABLES
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
        content: Text('Something went wrong ${Emojis.cryingFace}'),
      ));
    });
  }

  Future<void> updateUserProfile() async {
    try {
      if (ageController.text.isNotEmpty) {
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(context: context, age: ageController.text);
      }

      if (userNameController.text.isNotEmpty) {
        await Provider.of<FirestoreProvider>(context, listen: false)
            .instance
            .setAdditionalUserData(
                context: context, name: userNameController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile Updated ${Emojis.partyingFace}'),
      ));
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
              applicationVersion: 'Version: 0.9',
              applicationIcon: Logo()),
        ),
      ),
    );
  }

  Widget _changePasswordButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: GFButton(
          text: 'Change Password',
          type: GFButtonType.outline,
          onPressed: null,
        ),
      ),
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
                                      text: 'E-Mail (placeholder)',
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
                                    GFTypography(
                                      text: 'Phone (placeholder)',
                                      type: GFTypographyType.typo4,
                                      showDivider: false,
                                    ),
                                  ],
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
                                          hintText:
                                              'Enter Your Mobile Number (placeholder)',
                                        ),
                                        enabled: false,
                                        controller: phoneNumberController,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Container(
                                  child: GFTypography(
                                    text: 'Interests (placeholder)',
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
                                          hintText:
                                              'Enter Your Interests (placeholder)',
                                        ),
                                        enabled: false,
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
                                            onPressed: () {},
                                            icon: Icon(
                                              FontAwesomeIcons.plusCircle,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                          )
                                  ],
                                )),
                            Padding(
                              // TODO: implement interests
                              padding: const EdgeInsets.only(
                                  left: 32, right: 32, top: 8),
                              child: _status
                                  ? Wrap(
                                      spacing: 8.0,
                                      alignment: WrapAlignment.start,
                                      children: [
                                        'Play',
                                        'Football',
                                        'Riding',
                                        'Flutter',
                                        'Books',
                                        'Sport',
                                        'Climbing'
                                      ]
                                          .map((e) => FilterChip(
                                                label: Text(e),
                                                selected: true,
                                                onSelected: (bool value) {},
                                              ))
                                          .toList(),
                                    )
                                  : Wrap(
                                      spacing: 8.0,
                                      alignment: WrapAlignment.start,
                                      children: [
                                        'Play',
                                        'Football',
                                        'Riding',
                                        'Flutter',
                                        'Books',
                                        'Sport',
                                        'Climbing'
                                      ]
                                          .map((e) => FilterChip(
                                                label: Text(e),
                                                selected: _selected,
                                                selectedColor: Theme.of(context)
                                                    .accentColor,
                                                onSelected: (bool value) {
                                                  setState(() {
                                                    _selected = value;
                                                  });
                                                },
                                              ))
                                          .toList(),
                                    ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _logOutButton(),
                                _changePasswordButton(),
                                _aboutButton(),
                              ],
                            ),
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
                  userNameController.text = snapshot?.data?.name ??= '';
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
