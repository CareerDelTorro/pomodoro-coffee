import 'dart:async';
import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  SessionPageState createState() => SessionPageState();
}

class SessionPageState extends State<SessionPage> {
  Timer? _timer;
  int _remainingSeconds = 10;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        Navigator.pushNamed(context, '/results');
      }
    });
  }

  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null) {
      startTimer();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(timerText, style: TextStyle(fontSize: 48))],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
