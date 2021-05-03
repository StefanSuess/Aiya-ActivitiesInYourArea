import 'package:Aiya/constants.dart';
import 'package:Aiya/logo_widget.dart';
import 'package:Aiya/screens/only_mobile_support.dart';
import 'package:Aiya/services/authentication/auth_provider.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import 'signup_widget.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final navigatorKey = GlobalKey<NavigatorState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorCode = '';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _entryField(String title,
      {bool isPassword = false,
      TextInputType textInputType,
      @required TextEditingController textEditingController}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: textEditingController,
              obscureText: isPassword,
              keyboardType: textInputType,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)])),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white70,
          onTap: () => _emailLogin(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            child: Text(
              'Login',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        navigatorKey.currentState.pushNamed(constants.signUpRoute);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Logo();
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField('Email',
            textEditingController: emailController,
            textInputType: TextInputType.emailAddress),
        _entryField('Password',
            isPassword: true,
            textEditingController: passwordController,
            textInputType: TextInputType.text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // show notification that app is only for mobile phones
    if (MediaQuery.of(context).size.width > 800) {
      return OnlyMobileSupport();
    }

    return Scaffold(
        body: SafeArea(
      child: Navigator(
        key: navigatorKey,
        initialRoute: constants.loginRoute,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          // Manage your route names here
          switch (settings.name) {
            case constants.signUpRoute:
              builder = (BuildContext context) => SignUpPage();
              break;
            case constants.loginRoute:
              builder = (BuildContext context) => _loginWidget();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          // You can also return a PageRouteBuilder and
          // define custom transitions between pages
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        },
      ),
    ));
  }

  Widget _loginWidget() {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .08),
                  _title(),
                  SizedBox(height: height * .08),
                  _emailPasswordWidget(),
                  Text(
                    errorCode,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  _submitButton(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .auth
                            .resetPasswordLoginScreen(context);
                      },
                      child: Text('Forgot Password ?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  _divider(),
                  Container(
                      width: double.infinity,
                      height: 50,
                      child: SignInButton(Buttons.Facebook,
                          onPressed: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Sign in via Facebook is currently not supported ${Emojis.disappointedFace}'),
                                action: SnackBarAction(
                                  onPressed: () => ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(),
                                  label: 'OK',
                                ),
                              )))),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: double.infinity,
                      height: 50,
                      child: SignInButton(Buttons.Google,
                          onPressed: () =>
                              Provider.of<AuthProvider>(context, listen: false)
                                  .auth
                                  .signInWithGoogle(context))),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _emailLogin() async {
    errorCode = await Provider.of<AuthProvider>(context, listen: false)
        .auth
        .loginViaEmail(
            email: emailController.text.trim(),
            password: passwordController.text.trim());
    if (errorCode == null || errorCode == '') {
    } else {
      setState(() {});
    }
  }
}
