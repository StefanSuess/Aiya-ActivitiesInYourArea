import 'package:Aiya/data_models/profile_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:photo_view/photo_view.dart';

class ProfileExpanded extends StatefulWidget {
  final UserProfile userProfile;

  ProfileExpanded({Key key, @required this.userProfile}) : super(key: key);

  @override
  State createState() => ProfileExpandedState();
}

class ProfileExpandedState extends State<ProfileExpanded> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              widget.userProfile.age.isEmpty
                  ? GFListTile(
                      titleText: widget.userProfile.name,
                      subtitleText:
                          'Interestests: ${widget.userProfile.shortDescription}',
                    )
                  : GFListTile(
                      titleText:
                          '${widget.userProfile.name}, ${widget.userProfile.age}',
                      subtitleText:
                          'Interestests: ${widget.userProfile.shortDescription}',
                    ),
              Expanded(
                child: PhotoView(
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  basePosition: Alignment.topCenter,
                  imageProvider:
                      CachedNetworkImageProvider(widget.userProfile.photoURL),
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/blank_profile_picture.png'),
                ),
              ),
            ],
          ),
        ));
  }
}
