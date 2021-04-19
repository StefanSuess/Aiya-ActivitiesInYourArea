import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logo_widget.dart';

class SplashScreen extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    children: [
                      Text('Powered By'),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Image.asset(
                          'assets/images/farralls_logo.webp',
                        ),
                      )
                    ],
                  ))
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Logo(
                textSize: 100,
              )
            ],
          ),
        ],
      ),
    );
  }
}
