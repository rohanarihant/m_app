import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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

class BasicTimeField extends StatelessWidget {
  dynamic format = DateFormat("hh:mm a");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Basic time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
      ),
    ]);
  }
}

class AddYourReport extends StatefulWidget {
  const AddYourReport(this.userName, this.phone, this.gender, this.simranStarted, this.accessToken,
      {this.onMoveToHome, this.onSignedOut});
  final VoidCallback onMoveToHome;
  final VoidCallback onSignedOut;
  final String accessToken;
  final String userName;
  final String phone;
  final String gender;
  final bool simranStarted;

  @override
  State<StatefulWidget> createState() => _AddYourReportState();
}

enum FormType {
  login,
  register,
}

class _AddYourReportState extends State<AddYourReport> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _date = "";
  String _startTime = "Not set";
  String _endTime = "Not set";
  DateTime _startTimeStamp;
  DateTime _endTimeStamp;
  String _email;
  String _password;
  String _firstName;
  String _lastName;
  dynamic format = DateFormat("hh:mm a");
  final currentDate = DateFormat("yyyy-MM-dd");
  bool _isButtonDisabled = false;
  bool _isInAsyncCall = false;
  // String _phone;
  // String _accessToken;
  // String _username;
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
    print(validateAndSave());
    if (validateAndSave()) {
      formKey.currentState.save();
      dynamic diff = _endTimeStamp.difference(_startTimeStamp);
      print('the difference ${formatDate(diff)}');
      print(widget.gender);
      http.Response response =
          await http.post(Uri.encodeFull("${API_URL}/api/report"),
              headers: <String, String>{
                "Content-type": "application/json",
                "Authorization": "Bearer " + widget.accessToken,
              },
              body: jsonEncode({
                "name": widget.userName,
                "phone": widget.phone,
                "gender": widget.gender,
                "startTime": formatTime(_startTimeStamp),
	              "endTime": formatTime(_endTimeStamp),
                "data": '${_startTimeStamp.year}-${_startTimeStamp.month}-${_startTimeStamp.day}',
                "duration": formatDate(diff),
              }));
      print(response.body);
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

  void checkValidation() {
    if (_startTimeStamp != '' && _endTimeStamp != '') {
      _isButtonDisabled = true;
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
        title: Text('Add Your Report'),
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
            child: Form(
              key: formKey,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.phone,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: widget.simranStarted ? Colors.pinkAccent : Colors.blue,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Open Sans',
                        fontSize: 40)),
                SizedBox(
                  height: 60.0,
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
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2021));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      print(DateTimeField.combine(date, time));
                      _startTimeStamp = DateTimeField.combine(date, time);
                      checkValidation();
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                ),
                SizedBox(height: 20.0),

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
                      checkValidation();
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                ),
                SizedBox(
                  height: 20.0,
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
                    _isButtonDisabled ? submitReport() : null;
                    // widget.onMoveToHome();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              ]),
        ),
      ),
          //   ),
          // ),
        ),
        inAsyncCall: _isInAsyncCall,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      )
    );
  }
}
