import 'package:Aiya/data_models/activity_data.dart';
import 'package:flutter/material.dart';

class ExploreSearchBar extends StatefulWidget {
  final State parentState;
  ExploreSearchBar({Key key, @required this.parentState}) : super(key: key);
  @override
  _ExploreSearchBarState createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  final myController = TextEditingController();

  void filterActivities() {
    widget.parentState.setState(() {
      Activity.filteredActivityList.clear();
      Activity.filteredActivityList = Activity.activityList
          .where((element) => element.title
              .contains(RegExp(myController.value.text, caseSensitive: false)))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    myController.addListener(filterActivities);
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 4.0),
        child: TextField(
            controller: myController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for activities',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            )));
  }
}
