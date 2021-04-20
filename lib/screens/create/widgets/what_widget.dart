import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/getwidget.dart';

class WhatWidget extends StatefulWidget {
  final String title;

  // CALLBACKS
  final Function(String) titleCallback;

  // if given a title will pre populate its textfield
  WhatWidget({this.title, this.titleCallback, Key key}) : super(key: key);

  @override
  _WhatWidgetState createState() => _WhatWidgetState();
}

class _WhatWidgetState extends State<WhatWidget> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //check if arguments are not null
    if (widget != null && widget.title != null) {
      _textEditingController.text = widget.title;
      print(widget.title);
    }

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
            controller: _textEditingController,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: 'Eg. Playing Football, Go to a bar'),
          ),
        ],
      ),
    );
  }
}
