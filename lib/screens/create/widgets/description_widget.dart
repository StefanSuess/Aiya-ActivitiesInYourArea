import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';

class DescriptionWidget extends StatefulWidget {
  final String title;
  final Function(String) descriptionCallback;

  DescriptionWidget({Key key, this.descriptionCallback, this.title})
      : super(key: key);

  @override
  _DescriptionWidgetState createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget != null && widget.title != null) {
      _textEditingController.text = widget.title;
      print(widget.title);
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GFTypography(
            text: 'More information?',
            showDivider: false,
            type: GFTypographyType.typo1,
          ),
          TextField(
            autocorrect: true,
            minLines: 4,
            maxLines: 10,
            onChanged: (value) => widget.descriptionCallback(value),
            controller: _textEditingController,
            keyboardType: TextInputType.text,
            enableSuggestions: true,
            maxLength: 140,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText:
                    'You have 140 characters available to describe what you want to do if you want to'),
          ),
        ],
      ),
    );
  }
}
