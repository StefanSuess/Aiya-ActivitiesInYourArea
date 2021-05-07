import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/data_models/profile_data.dart';
import 'package:Aiya/screens/profile/profile_expanded.dart';
import 'package:Aiya/screens/profile/widgets/profile_picture_loader.dart';
import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:Aiya/services/firestore/firestore_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileShort extends StatefulWidget {
  final dynamic activityOrUserProfile;

  ProfileShort({Key key, this.activityOrUserProfile}) : super(key: key);

  @override
  _ProfileShortState createState() => _ProfileShortState();
}

class _ProfileShortState extends State<ProfileShort> {
  // the user id for fetching the short profile information
  String UID;

  Widget profileCreatorShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GFShimmer(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GFAvatar(
              size: 50,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 8,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    // check if either userProfile or Activity an retrieve the needed UID accordingly
    if (widget.activityOrUserProfile != null &&
        widget.activityOrUserProfile is UserProfile) {
      UID = (widget.activityOrUserProfile as UserProfile).uid;
    } else if (widget.activityOrUserProfile != null &&
        widget.activityOrUserProfile is Activity) {
      UID = (widget.activityOrUserProfile as Activity).creatorUID;
    }

    return FutureBuilder(
        future: Provider.of<AuthProvider>(context)
            .auth
            .getUserProfile(context: context, UID: UID),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return GFListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileExpanded(
                              userProfile: snapshot.data,
                            ))),
                avatar: ProfilePictureLoader(
                  imageURL: snapshot.data.photoURL ?? '',
                ),
                title: Text(
                  snapshot.data.age.isNotEmpty
                      ? '${snapshot.data.name}, ${snapshot.data.age}'
                      : '${snapshot.data.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: GFColors.DARK),
                ),
                subtitle: Text(
                  snapshot.data.shortDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.black54,
                  ),
                ),
                icon: StreamBuilder(
                    stream: Provider.of<FirestoreProvider>(context)
                        .instance
                        .getAdditionalUserDataAsStream(
                            context: context, uid: snapshot.data.uid),
                    builder: (BuildContext context,
                        AsyncSnapshot<UserProfile> snapshot) {
                      if (snapshot.hasError) throw snapshot.error.toString();
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return CircularProgressIndicator();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GFIconButton(
                                onPressed: // get allowed contact options
                                    snapshot.data.contactOptions
                                            .contains('WhatsApp')
                                        ? () async {
                                            var phone =
                                                snapshot.data.phoneNumber;
                                            var _url =
                                                "whatsapp://send?phone=$phone";
                                            await canLaunch(_url)
                                                ? await launch(_url)
                                                : ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Seems like you don\'t have WhatsApp ${Emojis.cryingFace}'),
                                                        action: SnackBarAction(
                                                          onPressed: () =>
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .removeCurrentSnackBar(),
                                                          label: 'OK',
                                                        )));
                                          }
                                        : null,
                                icon: Icon(
                                  FontAwesomeIcons.whatsapp,
                                ),
                                type: GFButtonType.transparent,
                              ),
                              GFIconButton(
                                onPressed: snapshot.data.contactOptions
                                        .contains('sms')
                                    ? () async {
                                        var phone = snapshot.data.phoneNumber;
                                        var _url = "sms:$phone";
                                        await canLaunch(_url)
                                            ? await launch(_url)
                                            : ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Something went wrong ${Emojis.cryingFace}'),
                                                    action: SnackBarAction(
                                                      onPressed: () =>
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar(),
                                                      label: 'OK',
                                                    )));
                                      }
                                    : null,
                                icon: Icon(
                                  FontAwesomeIcons.sms,
                                ),
                                type: GFButtonType.transparent,
                              ),
                              GFIconButton(
                                onPressed: () async {
                                  var phone = snapshot.data.phoneNumber;
                                  var _url = "tel:$phone";
                                  await canLaunch(_url)
                                      ? await launch(_url)
                                      : ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Something went wrong ${Emojis.cryingFace}'),
                                              action: SnackBarAction(
                                                onPressed: () =>
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .removeCurrentSnackBar(),
                                                label: 'OK',
                                              )));
                                },
                                icon: Icon(
                                  FontAwesomeIcons.phoneAlt,
                                ),
                                type: GFButtonType.transparent,
                              ),
                            ],
                          );
                      }
                      return profileCreatorShimmer();
                    }),
              );
            } else {
              return profileCreatorShimmer();
            }
          }
          return profileCreatorShimmer();
        });
  }
}
