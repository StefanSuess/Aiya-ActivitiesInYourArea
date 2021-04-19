import 'package:Aiya/screens/explore/widgets/activity_list_widget.dart';
import 'package:Aiya/screens/explore/widgets/main_search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/getwidget.dart';

class ExploreWidget extends StatefulWidget {
  @override
  _ExploreWidgetState createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            children: [
              ExploreSearchBar(
                parentState: this,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GFTypography(
                    text: 'Events near you',
                    type: GFTypographyType.typo1,
                  ),
                ),
              ),
            ],
          ),
        ),
        ActivityListCard()
      ],
    );
  }
}
