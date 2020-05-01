import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_demo/constants/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class MyReports extends StatefulWidget {
  MyReports(this.accessToken, this.simranStarted, this.id, {this.onMoveToHome});
  final dynamic accessToken;
  final VoidCallback onMoveToHome;
  final bool simranStarted;
  final int id;

  @override
  State createState() => new MyReportsState();
}

class MyReportsState extends State<MyReports> {
  List _myReports;
  bool _isInAsyncCall = false;

  @override
  void initState() {
    setState(() {
      _isInAsyncCall = true;
    });
    fetchMyReports();
  }

  Future fetchMyReports() async {
    http.Response response = await http.get(
        Uri.encodeFull('${API_URL}/api/report/${widget.id}'),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer " + widget.accessToken,
        });
    Map<String, dynamic> data = jsonDecode(response.body);
    setState(() {
      _myReports = data['content'];
      _isInAsyncCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onMoveToHome(),
        ),
        backgroundColor: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
        title: Text('My Reports'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout',
                style: TextStyle(fontSize: 17.0, color: Colors.white)),
          )
        ],
      ),
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: BodyLayout(_myReports, widget.simranStarted),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }
}

class BodyLayout extends StatelessWidget {
  final List _myReports;
  final bool _simranStarted;
  BodyLayout(this._myReports, this._simranStarted);
  @override
  Widget build(BuildContext context) {
    return _myReports != null && _myReports.length > 0
        ? _myListView(context, _myReports, _simranStarted)
        : Text("No Report Found",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Open Sans',
                fontSize: 30));
  }
}

Widget _myListView(BuildContext context, List _myReports, bool _simranStarted) {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: _myReports.length,
    itemBuilder: (context, index) {
      return Card(
        color: _simranStarted ? Colors.pink[50] : Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Name ${_myReports[index]["name"]}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Phone: ${_myReports[index]["phone"]}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Duration: ${_myReports[index]["duration"]}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Date: ${_myReports[index]["data"]}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Start: ${_myReports[index]["startTime"].split(" ")[1]}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text('End: ${_myReports[index]["endTime"].split(" ")[1]}',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
