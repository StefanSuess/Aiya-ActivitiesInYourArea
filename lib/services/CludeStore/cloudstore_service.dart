import 'dart:io';

import 'package:Aiya/services/user/auth_provider.dart';
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
}
