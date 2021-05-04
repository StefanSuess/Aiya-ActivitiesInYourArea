import 'package:Aiya/data_models/activity_data.dart';
import 'package:Aiya/screens/explore/widgets/activity_list_widget.dart';
import 'package:Aiya/screens/explore/widgets/main_search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreWidget extends StatefulWidget {
  @override
  _ExploreWidgetState createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  String dropdownValue = 'Date';

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
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Events near you',
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w800, fontSize: 28),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.sort),
                          iconSize: 32,
                          underline: Container(
                            height: 2,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                              switch (newValue) {
                                case 'Date':
                                  Activity.filteredActivityList.sort((a, b) =>
                                      a.dateTime.compareTo(b.dateTime));
                                  break;
                                case 'Location':
                                  Activity.filteredActivityList.sort((a, b) =>
                                      a.location.compareTo(b.location));
                                  break;
                                case 'Title':
                                  Activity.filteredActivityList.sort(
                                      (a, b) => a.title.compareTo(b.title));
                                  break;
                                default:
                              }
                            });
                          },
                          items: <String>['Date', 'Location', 'Title']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
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
