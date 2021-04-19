import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final double textSize;
  Logo({Key key, this.textSize = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'A',
          style: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: 'iy',
              style: TextStyle(color: Colors.black, fontSize: textSize),
            ),
            TextSpan(
              text: 'a',
              style: TextStyle(color: Color(0xffe46b10), fontSize: textSize),
            ),
          ]),
    );
  }
}
