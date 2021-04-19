import 'package:flutter/material.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:getwidget/types/gf_typography_type.dart';
import 'package:intl/intl.dart';

class WhenWidget extends StatefulWidget {
  // CALLBACKS
  final Function(TimeOfDay) timeCallback;
  final Function(DateTime) dateCallback;

  WhenWidget({this.dateCallback, this.timeCallback, Key key}) : super(key: key);

  @override
  _WhenWidgetState createState() => _WhenWidgetState();
}

class _WhenWidgetState extends State<WhenWidget> {
  // VARIABLES
  // TODO: show date and time according to user timezone
  final String _currentDate =
      DateFormat('dd-MM-yy').format(DateTime.now().toLocal());
  final String _currentTime =
      DateFormat('HH:mm').format(DateTime.now().toLocal());

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String test;

  // FUNCTIONS
  Future<Null> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
        widget.timeCallback(picked);
      });
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        // allow a maximum of 14 days into the future
        lastDate: DateTime.now().add(Duration(days: 14)));
    if (picked != null) {
      setState(() {
        // TODO: add leading zeros
        _dateController.text =
            '${picked.day.toString()}-${picked.month.toString()}-${picked.year.toString()}';
        widget.dateCallback(picked.toLocal());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GFTypography(
          text: 'When?',
          showDivider: false,
          type: GFTypographyType.typo1,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: _currentTime.toString()),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _dateController,
                  onTap: () => _selectDate(context),
                  readOnly: true,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: _currentDate.toString()),
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
