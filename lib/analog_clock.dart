import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter/material.dart';

class ClockDemo extends StatelessWidget {
  ClockDemo(this.simranStart);
  final bool simranStart;
  @override
  Widget build(BuildContext context) {
      return FlutterAnalogClock(
    hourNumbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
    dialPlateColor: Colors.white,
    hourHandColor: simranStart ? Colors.pinkAccent : Colors.blue,
    minuteHandColor: simranStart ? Colors.pinkAccent : Colors.blue,
    secondHandColor: simranStart ? Colors.pinkAccent : Colors.blue,
    tickColor: Colors.green,
    numberColor: simranStart ? Colors.pinkAccent : Colors.blue,
    centerPointColor: simranStart ? Colors.pinkAccent : Colors.blue,
    borderColor: simranStart ? Colors.pinkAccent : Colors.blue,
    borderWidth: 5,
    showSecondHand: true,
    showTicks: true,
    isLive: true,
    width: 300.0,
    height: 300.0,
  );
  }
}