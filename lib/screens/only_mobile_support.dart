import 'package:Aiya/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnlyMobileSupport extends StatefulWidget {
  OnlyMobileSupport({Key key}) : super(key: key);

  @override
  _OnlyMobileSupportState createState() => _OnlyMobileSupportState();
}

class _OnlyMobileSupportState extends State<OnlyMobileSupport> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: myTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Image.asset(
                  'assets/images/another_dimension.png',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height - 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'This app is designed for small screens like mobile phones. The experience can be buggy and is not representative of the app, but if you really want to use it on a PC you can resize your browser window and reload the website :)',
                          style: GoogleFonts.roboto(fontSize: 16),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 50,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Seems like your coming from another dimension',
                          style: GoogleFonts.roboto(fontSize: 32),
                          softWrap: true,
                        ),
                      ),
                    ))
              ],
            )));
  }
}
