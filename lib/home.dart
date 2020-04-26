import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:login_demo/constants/constants.dart';
import 'dart:convert';


class Home extends StatefulWidget {
  const Home(this.accessToken, this.simranStarted, {this.onMoveToAddReport, this.onMoveToTimer, this.onSignedOut, this.onMoveToAddSingleReport, this.onUserUpdate});
  final VoidCallback onMoveToAddSingleReport;
  final VoidCallback onMoveToAddReport;
  final VoidCallback onMoveToTimer;
  final VoidCallback onSignedOut;
  final dynamic onUserUpdate;
  final String accessToken;
  final bool simranStarted;

  @override
  State<StatefulWidget> createState() => _HomeState();

}

enum FormType {
  login,
  register,
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  FormType _formType = FormType.login;
  bool _showAddReportsType = false;

  // Future<String> getUserDetail() async {
  //   http.Response response = await http.get(
  //       Uri.encodeFull("${API_URL}/api/users/me"),
  //       headers: <String, String>{
  //         "Content-type": "application/json",
  //         "Authorization": "Bearer " + widget.accessToken
  //       });
  //   Map<String, dynamic> data = jsonDecode(response.body);
  //   print('data000${data['status']}');
  //   print(data['status'] == 401);
  //   if (data['status'] == 401) {
  //     widget.onSignedOut();
  //   }    // widget.onSignedIn();
  // }
//   @override
// void initState() {
//   getUserDetail();
//   // super.initState();
//   // SchedulerBinding.instance.addPostFrameCallback((_) => {});
// }
  List<Widget> toggleHomeWidget() {
    if (_showAddReportsType) {
      return <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: new Image.asset(
              'assets/images/home.jpg',
              height: 300.0,
              width: 300.0,
              fit: BoxFit.scaleDown,
            )),
        Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 80.0, right: 80.0),
            child: RaisedButton(
              onPressed: () {
                widget.onMoveToAddSingleReport();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  Text("Add Your Report",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  SizedBox(width: 20, height: 65),
                  Icon(Icons.person, color: Colors.white),
                ],
              ),
            )),
        Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.only(left: 80.0, right: 80.0),
          child: RaisedButton(
            onPressed: () {
              widget.onMoveToAddReport();
              // widget.onMoveToTimer();
            },
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Add Other's Report",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(width: 10, height: 65),
                Icon(Icons.people, color: Colors.white),
              ],
            ),
          ),
        )
      ];
    } else {
      return <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: new Image.asset(
              'assets/images/home.jpg',
              height: 300.0,
              width: 300.0,
              fit: BoxFit.scaleDown,
            )),
        Container(
            margin: EdgeInsets.only(top: 20.0),
            padding: EdgeInsets.only(left: 100.0, right: 100.0),
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  _showAddReportsType = true;
                });
                print('else ${_showAddReportsType}');
                // widget.onMoveToAddReport();
              },
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  Text("Add Report",
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  SizedBox(width: 20, height: 65),
                  Icon(Icons.add_circle, color: Colors.white),
                ],
              ),
            )),
        Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.only(left: 100.0, right: 100.0),
          child: RaisedButton(
            onPressed: () {
              widget.onMoveToTimer();
            },
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Start Meditation",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(width: 10, height: 65),
                Icon(Icons.timer, color: Colors.white),
              ],
            ),
          ),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
                  leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => 
          // _showAddReportsType ?
          setState(() { _showAddReportsType = false; })
          // widget.onMoveToAddReport() ,
        ),
        backgroundColor: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
          title: Text('Karnataka Meditation Report'),
          actions: <Widget>[
            FlatButton(
              child: Text('Logout',
                  style: TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () => widget.onSignedOut(),
            )
          ],
        ),
        body: Column(children: toggleHomeWidget()));
  }
}
