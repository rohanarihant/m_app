import 'package:flutter/material.dart';
import 'package:login_demo/auth.dart';
import 'package:login_demo/home_page.dart';
import 'package:login_demo/home.dart';
import 'package:login_demo/add_report.dart';
import 'package:login_demo/login_page.dart';
import 'package:login_demo/add_your_report.dart';
import 'package:login_demo/viewMyReports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  homePage,
  addReport,
  addSingleReport,
  timerScreen,
  viewMyReports,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  String _userName = '';
  String _phone = '';
  String _gender = '';
  String _email = '';
  String _accessToken = '';
  bool _simranStarted = false;
  int _id;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    SharedPreferences pref = await SharedPreferences.getInstance();
    dynamic checkLogin = pref.getBool("is_login");
    dynamic _simranStarted = pref.getBool("_simranStarted");
    setState(() {
      authStatus = checkLogin ? AuthStatus.homePage : AuthStatus.notDetermined;
      _simranStarted = _simranStarted;
    });
  }

  void _moveToHome() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      authStatus = AuthStatus.homePage;
    });
    pref.setBool("is_login", true);
  }

  void _signedOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
    pref.setBool("is_login", false);
  }

  void _moveToAddReport() {
    setState(() {
      authStatus = AuthStatus.addReport;
    });
  }

  void _moveToAddSingleReport() {
    setState(() {
      authStatus = AuthStatus.addSingleReport;
    });
  }

  void _moveToTimerScreen() {
    setState(() {
      authStatus = AuthStatus.timerScreen;
    });
  }

  void _onMoveToViewMyReports() {
    setState(() {
      authStatus = AuthStatus.viewMyReports;
    });
  }

  void _toggleThemeColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _simranStarted = !_simranStarted;
    });
    pref.setBool("_simranStarted", !_simranStarted);
  }

  void _updateAccessToken(String accessToken) {
    setState(() {
      _accessToken = accessToken;
    });
  }

  void _updateUser(String username, String phone, String gender,
      String accessToken, int id) {
    setState(() {
      _userName = username;
      _phone = phone;
      _gender = gender;
      _accessToken = accessToken;
      _id = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
      // return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _moveToHome,
          onUserUpdate: _updateAccessToken,
        );
      case AuthStatus.homePage:
        return Home(
          _accessToken,
          _simranStarted,
          onMoveToAddReport: _moveToAddReport,
          onMoveToTimer: _moveToTimerScreen,
          onMoveToAddSingleReport: _moveToAddSingleReport,
          onSignedOut: _signedOut,
          onUserUpdate: _updateUser,
          onMoveToViewMyReports: _onMoveToViewMyReports,
        );
      case AuthStatus.addReport:
        return AddReport(
          _accessToken,
          _simranStarted,
          _gender,
          onMoveToHome: _moveToHome,
          onSignedOut: _signedOut,
        );
      case AuthStatus.addSingleReport:
        return AddYourReport(
          _userName,
          _phone,
          _gender,
          _simranStarted,
          _accessToken,
          onMoveToHome: _moveToHome,
          onSignedOut: _signedOut,
        );
      case AuthStatus.timerScreen:
        return HomePage(
          _userName,
          _phone,
          _gender,
          _accessToken,
          _simranStarted,
          onMoveToHome: _moveToHome,
          onSignedOut: _signedOut,
          toggleThemeColor: _toggleThemeColor,
        );
      case AuthStatus.viewMyReports:
        return MyReports(
          _accessToken,
          _simranStarted,
          _id,
          onMoveToHome: _moveToHome,
          // onSignedOut: _signedOut,
        );
    }
    return null;
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
