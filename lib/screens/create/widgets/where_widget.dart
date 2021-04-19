import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';

class WhereWidget extends StatefulWidget {
  //CALLBACKS
  final Function(String) locationCallback;

  WhereWidget({this.locationCallback, Key key}) : super(key: key);

  @override
  _WhereWidgetState createState() => _WhereWidgetState();
}

class _WhereWidgetState extends State<WhereWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GFTypography(
          text: 'Where?',
          type: GFTypographyType.typo1,
          showDivider: false,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextField(
            onChanged: (value) => widget.locationCallback(value),
            autocorrect: true,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(), hintText: 'Search here'),
          ),
        ),
        /*Expanded( TODO implement maps correctly
              child: GoogleMapsMap(),
            )*/
      ],
    ));
  }
}
