import 'dart:io';
import 'dart:typed_data';

import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CloudStoreService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future uploadProfilePicture(File file, BuildContext context) async {
    var UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    await _firebaseStorage.ref('avatars/$UID.jpg').putFile(file);
    var downloadURL =
        await _firebaseStorage.ref('avatars/$UID.jpg').getDownloadURL();
    await await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .setPhotoURL(downloadURL, context);
  }

  Future uploadProfilePictureForWeb(
      Uint8List fileBytes, BuildContext context) async {
    var UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    await _firebaseStorage.ref('avatars/$UID.jpg').putData(fileBytes);
    var downloadURL =
        await _firebaseStorage.ref('avatars/$UID.jpg').getDownloadURL();
    await await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .setPhotoURL(downloadURL, context);
  }

  Future<String> uploadGroupChatPicture(File file, BuildContext context) async {
    var UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    var timestamp = Timestamp.now().millisecondsSinceEpoch.toString();
    // picturename = timestamp + UID (guaranteed individual name)
    var pictureName = '${timestamp}_$UID.jpg';
    await _firebaseStorage.ref('pictures/$pictureName').putFile(file);
    return await _firebaseStorage.ref('pictures/$pictureName').getDownloadURL();
  }

  Future<String> uploadGroupChatPictureForWeb(
      Uint8List fileBytes, BuildContext context) async {
    var UID = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .getCurrentUID();
    var timestamp = Timestamp.now().millisecondsSinceEpoch.toString();
    // picturename = timestamp + UID (guaranteed individual name)
    var pictureName = '${timestamp}_$UID.jpg';
    await _firebaseStorage.ref('pictures/$pictureName').putData(fileBytes);
    return await _firebaseStorage.ref('pictures/$pictureName').getDownloadURL();
  }
}
