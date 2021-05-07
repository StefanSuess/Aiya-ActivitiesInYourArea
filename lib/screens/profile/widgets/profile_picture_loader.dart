import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';

class ProfilePictureLoader extends StatefulWidget {
  final String imageURL;
  final double size;

  ProfilePictureLoader({this.imageURL = '', this.size = 50});

  @override
  _ProfilePictureLoaderState createState() => _ProfilePictureLoaderState();
}

class _ProfilePictureLoaderState extends State<ProfilePictureLoader> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageURL,
      fadeInCurve: Curves.elasticIn,
      imageBuilder: (context, imageProvider) => GFAvatar(
        size: widget.size,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => GFAvatar(
        size: widget.size,
        backgroundImage: AssetImage('assets/images/blank_profile_picture.png'),
      ),
      errorWidget: (context, url, error) => GFAvatar(
        size: widget.size,
        backgroundImage: AssetImage('assets/images/blank_profile_picture.png'),
      ),
    );
  }
}
