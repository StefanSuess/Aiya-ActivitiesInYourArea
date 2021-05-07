import 'package:Aiya/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: 'Thank you for testing Aiya :)',
      body: 'Aiya allows you to create and join local activities',
      image: Center(
          child: Logo(
        textSize: 75,
      )),
    ),
    PageViewModel(
      title: 'Aiya is in active development',
      body:
          'Expect crashes, online service unavailability, limited support and other weird behaviour\n\nIf you have any suggestions or find bugs please report them to me via WhatsApp, Email or however you like',
      image: SafeArea(
          child: Center(
              child: Image.asset('assets/images/undraw_programming.png'))),
    ),
    PageViewModel(
      title: 'You are not alone!',
      body:
          'You are not the only person who is using this app. Others can see your created activities, chosen name, profile picture ...\n\n So, please behave yourself and do not share sensitive information',
      image: SafeArea(
          child: Center(
              child: Image.asset('assets/images/undraw_develop_app.png'))),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      onDone: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstStart', false);
        Navigator.of(context).maybePop();
      },
      onSkip: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstStart', false);
        Navigator.of(context).maybePop();
        // You can also override onSkip callback
      },
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Text('Next', style: TextStyle(fontWeight: FontWeight.w600)),
      done: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).accentColor,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }
}
