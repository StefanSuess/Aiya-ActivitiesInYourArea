import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/getwidget.dart';

class WhatWidget extends StatefulWidget {
  // CALLBACKS
  final Function(String) titleCallback;

  WhatWidget({this.titleCallback, Key key}) : super(key: key);

  @override
  _WhatWidgetState createState() => _WhatWidgetState();
}

class _WhatWidgetState extends State<WhatWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GFTypography(
            text: 'What?',
            showDivider: false,
            type: GFTypographyType.typo1,
          ),
          TextField(
            autocorrect: true,
            onChanged: (value) => widget.titleCallback(value),
            decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Eg. Playing Football, Go to a bar'),
          ),
        ],
      ),
    );
  }
}
