import 'package:flutter/material.dart';
import 'package:login_demo/auth.dart';
import 'package:login_demo/auth_provider.dart';
import 'package:login_demo/root_page.dart';
import 'package:login_demo/time_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      final timerService = TimerService();
    return TimerServiceProvider(
      service: timerService,
      child: MaterialApp(
        title: 'Track Report',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(),
      ),
    );
  }
}
