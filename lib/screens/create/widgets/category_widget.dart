import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';

class CategoryChip {
  String label;
  String icon;
  bool selected;
  CategoryChip(String label, String icon, bool selected) {
    this.label = label;
    this.icon = icon;
    this.selected = selected;
  }
}

class CategoryWidget extends StatefulWidget {
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  int _value;

  List<CategoryChip> chips = [
    CategoryChip('Social', Emojis.huggingFace, false),
    CategoryChip('Fun', Emojis.smilingFace, false),
    CategoryChip('Party', Emojis.partyingFace, false),
    CategoryChip('Chill', Emojis.slightlySmilingFace, false)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 30,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: chips.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: ChoiceChip(
                        label: Text('${chips[index].label}'),
                        selected: chips[index].selected,
                        avatar: Text('${chips[index].icon}'),
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? index : null;
                            if (_value == index) {
                              chips[index].selected = true;
                            } else {
                              chips[index].selected = false;
                            }
                          });
                        },
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
