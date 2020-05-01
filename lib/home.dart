import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_demo/constants/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Home extends StatefulWidget {
  const Home(this.accessToken, this.simranStarted,
      {this.onMoveToAddReport,
      this.onMoveToTimer,
      this.onSignedOut,
      this.onMoveToAddSingleReport,
      this.onUserUpdate,
      this.onMoveToViewMyReports});
  final VoidCallback onMoveToAddSingleReport;
  final VoidCallback onMoveToAddReport;
  final VoidCallback onMoveToViewMyReports;
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
  bool _isInAsyncCall = false;

  Future<String> getUserDetail() async {
    setState(() {
      _isInAsyncCall = true;
    });
    http.Response response = await http.get(
        Uri.encodeFull("${API_URL}/api/users/me"),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer " + widget.accessToken
        });
    Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] == 401 || data['status'] == 500) {
      widget.onSignedOut();
    } else {
      widget.onUserUpdate(data['username'], data['phone'], data['gender'],
          widget.accessToken, data['id']);
    }
    setState(() {
      _isInAsyncCall = false;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getUserDetail();
  }

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
              color:
                  widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
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
            color: widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
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
            padding: EdgeInsets.only(top: 10.0),
            child: new Image.asset(
              'assets/images/home.jpg',
              height: 300.0,
              width: 300.0,
              fit: BoxFit.scaleDown,
            )),
        Container(
            margin: EdgeInsets.only(top: 10.0),
            padding: EdgeInsets.only(left: 100.0, right: 80.0),
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  _showAddReportsType = true;
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color:
                  widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
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
          padding: EdgeInsets.only(left: 100.0, right: 80.0),
          child: RaisedButton(
            onPressed: () {
              widget.onMoveToTimer();
            },
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
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
        ),
        Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.only(left: 100.0, right: 80.0),
          child: RaisedButton(
            onPressed: () {
              widget.onMoveToViewMyReports();
            },
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("View My Reports",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                SizedBox(width: 10, height: 65),
                Icon(Icons.library_books, color: Colors.white),
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
                  setState(() {
                    _showAddReportsType = false;
                  })
              ),
          backgroundColor:
              widget.simranStarted ? Colors.pinkAccent : Colors.blue[400],
          title: Text('Karnataka Meditation Report'),
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
                child: Column(children: toggleHomeWidget())),
          ),
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ));
  }
}
