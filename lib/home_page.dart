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

class HomePage extends StatefulWidget {
  const HomePage(this.userName, this.phone, this.accessToken,this.simranStarted,
      {this.onMoveToHome, this.onSignedOut, this.toggleThemeColor});
  final VoidCallback onSignedOut;
  final VoidCallback onMoveToHome;
  final VoidCallback toggleThemeColor;
  final String userName;
  final String phone;
  final String accessToken;
  final bool simranStarted;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  dynamic format(String d) => d.toString().split('.').first.padLeft(8, '0');
  dynamic formatDate(Duration d) =>
      d.toString().split('.').first.padLeft(8, '0');
  DateTime currentDate = new DateTime.now();
  dynamic currentTime;
  dynamic _startTime;
  DateTime _startTimeStamp;
  dynamic _endTime;
  DateTime _endTimeStamp;
  
  // var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);

  Future submitReport(String diff) async {
    print(widget.accessToken);
    print(widget.userName);
    print(widget.phone);
    print(diff);
    print('${currentDate.year}-${currentDate.month}-${currentDate.day}');
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
            }));
    print(response.body);
    Map<String, dynamic> data = jsonDecode(response.body);
  }

  dynamic getDifference() {
    dynamic diff = _endTimeStamp.difference(_startTimeStamp);
    setState(() {
      _startTime = null;
      _startTimeStamp = null;
      _endTime = null;
      _endTimeStamp = null;
    });
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(isRegisterPopup: false,valueNotifier: formatDate(diff)));
  }

    @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    // final BaseAuth auth = AuthProvider.of(context).auth;
    // auth.currentUser().then((String userId) {
      var timerService = TimerService.of(context);
      SharedPreferences pref = await SharedPreferences.getInstance();
      dynamic isRunning = pref.getBool("isRunning");
      dynamic checkIsRunning = (isRunning == null) ? false : true;
      if(checkIsRunning){
        timerService.start();
        setState(() {
           _startTime = pref.getString("startTime");
      _startTimeStamp = DateTime.fromMillisecondsSinceEpoch(pref.getInt("startTimeStamp"));
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
      body: Center(
        child: AnimatedBuilder(
          animation: timerService, // listen to ChangeNotifier
          builder: (context, child) {
            // this part is rebuilt whenever notifyListeners() is called
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Padding(padding: EdgeInsets.only(top: 0.0),child:new Image.asset('assets/images/meditation.jpeg',height: 300.0,width: 300.0,fit: BoxFit.scaleDown,)),
                SizedBox(
                  height: 20.0,
                ),
                ClockDemo(widget.simranStarted),
                 SizedBox(
                  height: 20.0,
                ),
                Text('${currentDate.year}-${currentDate.month}-${currentDate.day}',
                        textAlign: TextAlign.center,
                    style: TextStyle(
                        color:  widget.simranStarted ? Colors.pinkAccent : Colors.blue,
                        fontWeight: FontWeight.w900,
                        // fontStyle: FontStyle.italic,
                        fontFamily: 'Open Sans',
                        fontSize: 18)),
                          SizedBox(
                  height: 20.0,
                ),
                _startTime != null
                    ? Text('Started at - ' + _startTime,
                        textAlign: TextAlign.center,
                    style: TextStyle(
                        color:  widget.simranStarted ? Colors.pinkAccent : Colors.blue,
                        fontWeight: FontWeight.w500,
                        // fontStyle: FontStyle.italic,
                        fontFamily: 'Open Sans',
                        fontSize: 30))
                    : Text(''),
                // Text(format('${timerService.currentDuration}'),
                //     style: TextStyle(fontSize: 40.0)),
                // RaisedButton(
                //   onPressed: !timerService.isRunning ? timerService.start : timerService.stop,
                //   child: Text(!timerService.isRunning ? 'Start' : 'Stop'),
                // ),
                SizedBox(
                  height: 20.0,
                ),
                !timerService.isRunning
                    ?  SizedBox(
                  width: 200.0,
                  child: FloatingActionButton.extended(
                        onPressed: () {
                          if (!timerService.isRunning) {
                            // date = TimeOfDay.fromDateTime(DateTime.now());
                            widget.toggleThemeColor();
                            timerService.start();
                            // print(date);
                            setState(() async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("startTime", DateFormat.jm().format(DateTime.now()));
                                    pref.setInt("startTimeStamp", new DateTime.now().millisecondsSinceEpoch);
                                    pref.setBool("isRunning", true);
                              _startTime =
                                  DateFormat.jm().format(DateTime.now());
                              _startTimeStamp = new DateTime.now();
                            });
                          }
                          // showDialog<dynamic>(context: context, builder: (BuildContext context) => CustomDialog(valueNotifier: format('${timerService.currentDuration}'),endTimer:timerService.reset));
                        },
                        label: Text('Start',textAlign: TextAlign.center,style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                        fontSize: 30)),
                        icon: Icon(Icons.av_timer, size: 30.0,),
                        
                        // backgroundColor: Colors.blue,
                        backgroundColor: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
                      ))
                    : SizedBox(
                  width: 200.0,
                  child:FloatingActionButton.extended(
                        onPressed: () async{
                          if (timerService.isRunning) {
                            timerService.stop;
                          }
                          print(_startTime);
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          await pref.remove('startTime');
                          await pref.remove('startTimeStamp');
                          await pref.remove('isRunning');
                          setState(() {
                            _endTime = DateFormat.jm().format(DateTime.now());
                            _endTimeStamp = new DateTime.now();
                          });
                          getDifference();
                          widget.toggleThemeColor();
                          timerService.reset();
                        },
                        label: Text('Submit',textAlign: TextAlign.center,style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                        fontSize: 30)),
                        icon: Icon(Icons.report, size: 30.0,),
                        backgroundColor:  widget.simranStarted ? Colors.pinkAccent : Colors.blue ,
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}
