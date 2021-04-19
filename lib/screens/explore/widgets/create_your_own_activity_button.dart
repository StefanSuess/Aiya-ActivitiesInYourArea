import 'package:Aiya/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:getwidget/types/gf_button_type.dart';

class CreateYourOwnActivityButton extends StatefulWidget {
  @override
  _CreateYourOwnActivityButtonState createState() =>
      _CreateYourOwnActivityButtonState();
}

class _CreateYourOwnActivityButtonState
    extends State<CreateYourOwnActivityButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            child: GFButton(
          size: GFSize.LARGE,
          text: 'Create Your Own Activity',
          icon: Icon(
            FontAwesomeIcons.plus,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(constants.createRoute);
          },
          type: GFButtonType.outline2x,
        )),
      ],
    );
  }
}
