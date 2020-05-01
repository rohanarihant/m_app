import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_demo/time_service.dart';
import 'package:login_demo/custom_dialog.dart';
import 'package:intl/intl.dart';
import 'package:login_demo/constants/constants.dart';
import 'package:login_demo/analog_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.userName, this.phone, this.gender, this.accessToken,
      this.simranStarted,
      {this.onMoveToHome, this.onSignedOut, this.toggleThemeColor});
  final VoidCallback onSignedOut;
  final VoidCallback onMoveToHome;
  final VoidCallback toggleThemeColor;
  final String userName;
  final String phone;
  final String accessToken;
  final String gender;
  final bool simranStarted;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  dynamic format(String d) => d.toString().split('.').first.padLeft(8, '0');
  dynamic formatDuartion(Duration d) =>
      d.toString().split('.').first.padLeft(8, '0');
  dynamic formatTime(DateTime d) =>
      d.toString().split('.').first.padLeft(8, '0');
  DateTime currentDate = new DateTime.now();
  dynamic currentTime;
  dynamic _startTime;
  DateTime _startTimeStamp;
  dynamic _endTime;
  DateTime _endTimeStamp;
  bool _isInAsyncCall = false;

  Future submitReport(String diff) async {
    var timerService = TimerService.of(context);
    http.Response response =
        await http.post(Uri.encodeFull("${API_URL}/api/report"),
            headers: <String, String>{
              "Content-type": "application/json",
              "Authorization": "Bearer " + widget.accessToken,
            },
            body: jsonEncode(<String, String>{
              "name": widget.userName,
              "phone": widget.phone,
              "data":
                  '${currentDate.year}-${currentDate.month}-${currentDate.day}',
              "duration": diff,
              "startTime": formatTime(_startTimeStamp),
              "endTime": formatTime(_endTimeStamp),
              "gender": widget.gender,
            }));
    Map<String, dynamic> data = jsonDecode(response.body);
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(isRegisterPopup: false, valueNotifier: diff));

    setState(() {
      _startTime = null;
      _startTimeStamp = null;
      _endTime = null;
      _endTimeStamp = null;
      _isInAsyncCall = false;
    });
    widget.toggleThemeColor();
    timerService.reset();
  }

  dynamic getDifference() {
    setState(() {
      _isInAsyncCall = true;
    });
    dynamic diff = _endTimeStamp.difference(_startTimeStamp);
    submitReport(formatDuartion(diff));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var timerService = TimerService.of(context);
    SharedPreferences pref = await SharedPreferences.getInstance();
    dynamic isRunning = pref.getBool("isRunning");
    dynamic checkIsRunning =
        ((isRunning == null) || isRunning == false) ? false : true;
    if (checkIsRunning) {
      timerService.start();
      setState(() {
        _startTime = pref.getString("startTime");
        _startTimeStamp =
            DateTime.fromMillisecondsSinceEpoch(pref.getInt("startTimeStamp"));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onMoveToHome(),
        ),
        backgroundColor: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
        title: Text("Meditation Timer"),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout',
                style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () => widget.onSignedOut(),
          )
        ],
      ),
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AnimatedBuilder(
                animation: timerService, 
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      ClockDemo(widget.simranStarted),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                          '${currentDate.year}-${currentDate.month}-${currentDate.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: widget.simranStarted
                                  ? Colors.pinkAccent
                                  : Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Open Sans',
                              fontSize: 18)),
                      SizedBox(
                        height: 20.0,
                      ),
                      _startTime != null
                          ? Text('Started at - ' + _startTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: widget.simranStarted
                                      ? Colors.pinkAccent
                                      : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Open Sans',
                                  fontSize: 30))
                          : Text(''),
                      SizedBox(
                        height: 20.0,
                      ),
                      !timerService.isRunning
                          ? SizedBox(
                              width: 200.0,
                              child: FloatingActionButton.extended(
                                onPressed: () {
                                  if (!timerService.isRunning) {
                                    widget.toggleThemeColor();
                                    timerService.start();
                                    setState(() async {
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      pref.setString(
                                          "startTime",
                                          DateFormat.jm()
                                              .format(DateTime.now()));
                                      pref.setInt(
                                          "startTimeStamp",
                                          new DateTime.now()
                                              .millisecondsSinceEpoch);
                                      pref.setBool("isRunning", true);
                                      _startTime = DateFormat.jm()
                                          .format(DateTime.now());
                                      _startTimeStamp = new DateTime.now();
                                    });
                                  }
                                },
                                label: Text('Start',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Open Sans',
                                        fontSize: 30)),
                                icon: Icon(
                                  Icons.av_timer,
                                  size: 30.0,
                                ),
                                backgroundColor: widget.simranStarted
                                    ? Colors.pinkAccent
                                    : Colors.blue,
                              ))
                          : SizedBox(
                              width: 200.0,
                              child: FloatingActionButton.extended(
                                onPressed: () async {
                                  if (timerService.isRunning) {
                                    timerService.stop;
                                  }
                                  SharedPreferences pref =
                                      await SharedPreferences.getInstance();
                                  await pref.remove('startTime');
                                  await pref.remove('startTimeStamp');
                                  await pref.remove('isRunning');
                                  setState(() {
                                    _endTime =
                                        DateFormat.jm().format(DateTime.now());
                                    _endTimeStamp = new DateTime.now();
                                  });
                                  getDifference();
                                },
                                label: Text('Submit',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Open Sans',
                                        fontSize: 30)),
                                icon: Icon(
                                  Icons.report,
                                  size: 30.0,
                                ),
                                backgroundColor: widget.simranStarted
                                    ? Colors.pinkAccent
                                    : Colors.blue,
                              )),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}
