import 'package:flutter/material.dart';
import 'package:login_demo/constants/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:login_demo/custom_dialog.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class FirstNameFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Name can\'t be empty' : null;
    // return value.length < 3 ? 'Name should be more then 3 characters' : null;
  }
}

class LastNameFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Name can\'t be empty' : null;
    // return value.length < 3 ? 'Name should be more then 3 characters' : null;
  }
}

class PhoneFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Phone can\'t be empty' : null;
    // return value.length < 3 ? 'Name should be more then 3 characters' : null;
  }
}

class AddReport extends StatefulWidget {
  const AddReport(this.accessToken, this.simranStarted, this.gender,
      {this.onMoveToHome, this.onSignedOut});
  final VoidCallback onMoveToHome;
  final VoidCallback onSignedOut;
  final String accessToken;
  final String gender;
  final bool simranStarted;

  @override
  State<StatefulWidget> createState() => _AddReportState();
}

enum FormType {
  login,
  register,
}

class _AddReportState extends State<AddReport> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _date = "Not set";
  String _startTime = "Not set";
  String _endTime = "Not set";
  DateTime _startTimeStamp;
  DateTime _endTimeStamp;
  String _password;
  String _firstName;
  String _lastName;
  String _phone;
  String _username;
  bool _isInAsyncCall = false;

  dynamic format = DateFormat("hh:mm a");

  FormType _formType = FormType.login;
  dynamic formatDate(Duration d) =>
      d.toString().split('.').first.padLeft(8, '0');
  dynamic formatTime(DateTime d) =>
      d.toString().split('.').first.padLeft(8, '0');
  @override
  void initState() {
    super.initState();
  }

  bool validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future submitReport() async {
         setState(() {
       _isInAsyncCall = true;
      });
    if (validateAndSave()) {
      formKey.currentState.save();
      dynamic diff = _endTimeStamp.difference(_startTimeStamp);
      http.Response response =
          await http.post(Uri.encodeFull("${API_URL}/api/report"),
              headers: <String, String>{
                "Content-type": "application/json",
                "Authorization": "Bearer " + widget.accessToken,
              },
              body: jsonEncode(<String, String>{
                "name": _firstName + _lastName,
                "phone": _phone,
                "gender": widget.gender,
                "startTime": formatTime(_startTimeStamp),
                "endTime": formatTime(_endTimeStamp),
                "data":
                    '${_startTimeStamp.year}-${_startTimeStamp.month}-${_startTimeStamp.day}',
                "duration": formatDate(diff),
              }));
      Map<String, dynamic> data = jsonDecode(response.body);
             setState(() {
       _isInAsyncCall = false;
      });
      if (data['status'] == 401) {
        widget.onSignedOut();
      } else {
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) =>
                CustomDialog(isRegisterPopup: false,valueNotifier: formatDate(diff)));
        widget.onMoveToHome();
      }
    }
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
        title: Text('Add Other`s Report'),
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
        padding: EdgeInsets.all(4.0),
        child: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                 SizedBox(
                  height: 40.0,
                ),
                TextFormField(
                  key: Key('First Name'),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                  validator: FirstNameFieldValidator.validate,
                  onSaved: (String value) => _firstName = value,
                ),
                 SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  key: Key('Last Name'),
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                  validator: LastNameFieldValidator.validate,
                  onSaved: (String value) => _lastName = value,
                ),
                 SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  key: Key('Phone'),
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                  validator: PhoneFieldValidator.validate,
                  onSaved: (String value) => _phone = value,
                ),
                SizedBox(
                  height: 20.0,
                ),
                DateTimeField(
                  format: format,
                  decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: widget.simranStarted ? Colors.pinkAccent : Colors.blue))),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        initialDate: DateTime.now(),
                        lastDate: DateTime(2021));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      print(DateTimeField.combine(date, time));
                      _startTimeStamp = DateTimeField.combine(date, time);
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                DateTimeField(
                  format: format,
                  decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: widget.simranStarted ? Colors.pinkAccent : Colors.blue))),
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        initialDate: DateTime.now(),
                        lastDate: DateTime(2021));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      print(DateTimeField.combine(date, time));
                      _endTimeStamp = DateTimeField.combine(date, time);
                      // checkValidat ion();
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                FlatButton(
                  color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: widget.simranStarted ? Colors.pinkAccent : Colors.blueAccent,
                  onPressed: () {
                    submitReport();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              ]),
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
