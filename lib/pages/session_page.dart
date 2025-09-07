import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomodoro_coffee/app_state.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  SessionPageState createState() => SessionPageState();
}

class SessionPageState extends State<SessionPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  TimerMode _currentMode = TimerMode.workTime;
  int numSessionsLeft = 0;
  Color backgroundColor = Colors.red;
  bool isRunning = false;

  void setTimer(int durationMin) {
    setState(() {
      _remainingSeconds = durationMin;
    });
  }

  void startTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        resolveTimerEnd();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
    ;
  }

  void resolveTimerEnd() {
    if (_currentMode == TimerMode.workTime) {
      numSessionsLeft--;
    }
    if (numSessionsLeft > 0) {
      switchMode(_currentMode);
    } else {
      _timer?.cancel();
      setState(() {
        isRunning = false;
      });
      Navigator.pushNamed(context, '/results');
    }
  }

  void switchMode(TimerMode mode) {
    final appState = Provider.of<AppState>(context, listen: false);
    switch (_currentMode) {
      case TimerMode.workTime:
        _currentMode = TimerMode.breakTime;
        setTimer(appState.breakDuration);
        startTimer();
        changeBackgroundColour(TimerMode.breakTime);
        break;
      case TimerMode.breakTime:
        _currentMode = TimerMode.workTime;
        setTimer(appState.workDuration);
        startTimer();
        changeBackgroundColour(TimerMode.workTime);
        break;
    }
  }

  void changeBackgroundColour(TimerMode mode) {
    setState(() {
      backgroundColor = mode == TimerMode.workTime ? Colors.red : Colors.green;
    });
  }

  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    // Delay access to context until after initState using addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        numSessionsLeft = appState.numSessionsTotal;
        setTimer(appState.workDuration);
        startTimer();
        changeBackgroundColour(TimerMode.workTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    Widget playPauseButton = isRunning
        ? ElevatedButton(onPressed: pauseTimer, child: Text('Pause'))
        : ElevatedButton(onPressed: startTimer, child: Text('Play'));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timerText, style: TextStyle(fontSize: 48)),
            Text(
              _currentMode == TimerMode.workTime ? 'Work Time' : 'Break Time',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Session ${appState.numSessionsTotal + 1 - numSessionsLeft} / ${appState.numSessionsTotal}',
              style: TextStyle(fontSize: 24),
            ),
            playPauseButton,
          ],
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

enum TimerMode { workTime, breakTime }
