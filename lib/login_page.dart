import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:login_demo/constants/constants.dart';
import 'package:gender_selector/gender_selector.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:login_demo/custom_dialog.dart';

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty && !(value.length > 5)
        ? 'Password should contains more then 5 character'
        : null;
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
    return value.isEmpty && value.length < 4
        ? 'Last Name can\'t be empty'
        : null;
    // return value.length < 3 ? 'Name should be more then 3 characters' : null;
  }
}

class PhoneFieldValidator {
  static String validate(String value) {
    return value.isEmpty && value.length < 4
        ? 'Phone Number should contains atleast 10 character'
        : null;
    // return value.length < 3 ? 'Name should be more then 3 characters' : null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({this.onUserUpdate, this.onSignedIn});
  final VoidCallback onSignedIn;
  final dynamic onUserUpdate;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType {
  login,
  register,
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _firstName;
  String _lastName;
  String _phone;
  String _accessToken;
  String _username;
  String _error;
  String _gender = "male";
  Gender selectGender = Gender.MALE;
  bool _hasError = false;
  bool _isInAsyncCall = false;

  FormType _formType = FormType.login;

  Future<String> getLogin() async {
    http.Response response = await http.post(
        Uri.encodeFull("${API_URL}/api/auth/signin"),
        headers: <String, String>{
          "Content-type": "application/json",
        },
        body: jsonEncode(
            <String, String>{"phoneOrEmail": _email, "password": _password}));
    Map<String, dynamic> data = jsonDecode(response.body);
    print(data);
    String accessToken = '';
    int status = 0;
    accessToken = data['accessToken'];
    status = data['status'];
     setState(() {
       _isInAsyncCall = false;
      });
    if (status == 401) {
      setState(() {
        _hasError = true;
        _error = 'Invalid Credentials!';
      });
    } else if (status == 500) {
      setState(() {
        _hasError = true;
        _error = data['message'];
      });
    } else if (accessToken != '') {
      setState(() {
        _hasError = false;
        _accessToken = accessToken;
      });
      getUserDetail();
      widget.onSignedIn();
    }
  }

  Future<String> getUserDetail() async {
    http.Response response = await http.get(
        Uri.encodeFull("${API_URL}/api/users/me"),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer " + _accessToken
        });
    print('data000${response}');
    Map<String, dynamic> data = jsonDecode(response.body);
    print('data111${data}');
    widget.onUserUpdate(
        data["username"], data["phone"], data["gender"], _accessToken);
    if (mounted) {
      print('data222${data}');
      setState(() {
        _phone = data["phone"];
        _username = data["username"];
      });
    }
    widget.onSignedIn();
  }

  Future<String> getRegister() async {
    http.Response response =
        await http.post(Uri.encodeFull("${API_URL}/api/auth/signup"),
            headers: <String, String>{
              "Content-type": "application/json",
            },
            body: jsonEncode({
              "firstName": _firstName,
              "lastName": _lastName,
              "email": _email,
              "username": _firstName + _lastName,
              "phone": _phone,
              "password": _password,
              "gender": _gender,
              "active": false
            }));
    print(response.body);
    Map<String, dynamic> map = jsonDecode(response.body);
    bool responseType = false;
                setState(() {
            _isInAsyncCall = false;
            });
    responseType = map['success'];
    int responseStatus = map['status'];
    String responseMessage = map['message'];
    if (responseStatus == 500) {
      setState(() {
        _hasError = true;
        _error = map['message'];
      });
    } else if (responseStatus == 400) {
      dynamic tempMessage = map['messages'];
      setState(() {
        _hasError = true;
        _error = tempMessage[0];
      });
    } else {
      setState(() {
        _hasError = false;
      });
      showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) =>
        CustomDialog(isRegisterPopup: true,valueNotifier: null));
      moveToLogin();
    }
  }

//  @override
//  void initState() {
//    super.initState();
//    getData();
//  }

  bool validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      formKey.currentState.save();
      try {
        if (_formType == FormType.login) {
            setState(() {
            _isInAsyncCall = true;
            });
          getLogin();
          // widget.onSignedIn();
        } else {
            setState(() {
            _isInAsyncCall = true;
            });
          getRegister();
        }
        // widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    print(_hasError);
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _hasError = false;
      _error = '';
    });
  }

  void moveToLogin() {
    print(_hasError);
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _hasError = false;
      _error = '';
    });
  }

  String ShowError() {
    if (_hasError) {
      return _error;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('_isInAsyncCall ${_isInAsyncCall}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Bangalore Meditation Report App'),
      ),
      // body: Container(
      //             color: Colors.indigoAccent,

      //   // padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
      //   // child: Form(
      //   //   key: formKey,
      //   //   child: Column(
      //   //     crossAxisAlignment: CrossAxisAlignment.stretch,
      //   //     children: buildInputs() + buildSubmitButtons(),
      //   //   ),
      //   // ),
      // ),
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildInputs() + buildSubmitButtons(),
              ),
            ),
          ),
        ),
        inAsyncCall: _isInAsyncCall,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType != FormType.login) {
      return <Widget>[
        SizedBox(
          height: 20.0,
        ),
        TextFormField(
          key: Key('First Name'),

          // decoration: InputDecoration(labelText: 'First Name'),
          decoration: InputDecoration(
            labelText: 'First Name',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          validator: FirstNameFieldValidator.validate,
          onSaved: (String value) => _firstName = value,
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          key: Key('Last Name'),
          // decoration: InputDecoration(labelText: 'Last Name'),
          decoration: InputDecoration(
            labelText: 'Last Name',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          validator: LastNameFieldValidator.validate,
          onSaved: (String value) => _lastName = value,
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          key: Key('email'),
          // decoration: InputDecoration(labelText: 'Email'),
          decoration: InputDecoration(
            labelText: 'Email',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          validator: EmailFieldValidator.validate,
          onSaved: (String value) => _email = value,
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          key: Key('password'),
          // decoration: InputDecoration(labelText: 'Password'),
          decoration: InputDecoration(
            labelText: 'Password',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          obscureText: true,
          validator: PasswordFieldValidator.validate,
          onSaved: (String value) => _password = value,
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          key: Key('Phone'),
          // decoration: InputDecoration(labelText: 'Phone'),
          decoration: InputDecoration(
            labelText: 'Phone',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          validator: PhoneFieldValidator.validate,
          onSaved: (String value) => _phone = value,
        ),
        SizedBox(
            height: _hasError ? 80.0 : 100.0,
            width: 80.0,
            child: GenderSelector(
              margin: EdgeInsets.only(top: 10, bottom: 0),
              // padding: EdgeInsets.all(15.0),
              selectedGender: selectGender,
              onChanged: (gender) async {
                setState(() {
                  print(gender);
                  if (gender == Gender.FEMALE) {
                    _gender = "female";
                  } else {
                    _gender = "male";
                  }
                  selectGender = gender;
                });
                print(selectGender);
                print(_gender);
              },
            )),
      ];
    } else {
      return <Widget>[
        SizedBox(
          height: 40.0,
        ),
        TextFormField(
          key: Key('Phone Number'),
          // decoration: InputDecoration(labelText: 'Phone Number'),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          validator: PhoneFieldValidator.validate,
          onSaved: (String value) => _email = value,
        ),
        SizedBox(
          height: 20.0,
        ),
        TextFormField(
          key: Key('Password'),
          // decoration: InputDecoration(labelText: 'Password'),
          decoration: InputDecoration(
            labelText: 'Password',
            contentPadding:
                new EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          ),
          obscureText: true,
          validator: PasswordFieldValidator.validate,
          onSaved: (String value) => _password = value,
        )
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return <Widget>[
        SizedBox(
          height: _hasError ? 10.0 : 0.0,
        ),
        Text(this.ShowError(),
            style: TextStyle(fontSize: 15.0, color: Colors.red)),
        SizedBox(
          height: _hasError ? 10.0 : 0.0,
        ),
        RaisedButton(
          key: Key('signIn'),
          child: Text('Login', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return <Widget>[
        SizedBox(
          height: _hasError ? 5.0 : 0.0,
        ),
        Text(this.ShowError(),
            style: TextStyle(fontSize: 15.0, color: Colors.red)),
        SizedBox(
          height: _hasError ? 5.0 : 0.0,
        ),
        RaisedButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child:
              Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
