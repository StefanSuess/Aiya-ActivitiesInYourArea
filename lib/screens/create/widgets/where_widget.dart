import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';

class WhereWidget extends StatefulWidget {
  final String where;

  //CALLBACKS
  final Function(String) locationCallback;

  WhereWidget({this.locationCallback, this.where, Key key}) : super(key: key);

  @override
  _WhereWidgetState createState() => _WhereWidgetState();
}

class _WhereWidgetState extends State<WhereWidget> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // check if arguments are given, if yes insert them accordingly (edit mode)
    if (widget.where != null) {
      textEditingController.text = widget.where;
    }

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
            controller: textEditingController,
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
