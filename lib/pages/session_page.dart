import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pomodoro_coffee/app_state.dart';
import 'package:pomodoro_coffee/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  SessionPageState createState() => SessionPageState();
}

class SessionPageState extends State<SessionPage> {
  Timer? _timer;
  int _remainingSecondsSession = 0;
  TimerMode _currentMode = TimerMode.workTime;
  int numSessionsLeft = 0;
  Color backgroundColor = Colors.red;
  bool isRunning = false;

  void setTimer(int durationMin) {
    setState(() {
      _remainingSecondsSession = durationMin;
    });
  }

  void startTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSecondsSession > 0) {
        setState(() {
          _remainingSecondsSession--;
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
  }

  void resetCurrentTimer() {
    final appState = Provider.of<AppState>(context, listen: false);
    switch (_currentMode) {
      case TimerMode.workTime:
        setTimer(appState.workDuration);
        break;
      case TimerMode.breakTime:
        setTimer(appState.breakDuration);
        break;
    }
  }

  void resolveTimerEnd() {
    if (_currentMode == TimerMode.workTime) {
      numSessionsLeft--;
    }
    if (numSessionsLeft > 0) {
      switchMode(_currentMode);
    } else {
      _timer?.cancel();
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
      backgroundColor = mode == TimerMode.workTime
          ? const Color(0xFFFAF8F4)
          : const Color(0xFF4AA5C1);
    });
  }

  int calculateTotalTimeLeftInSeconds() {
    final appState = Provider.of<AppState>(context, listen: false);

    int totalTimeLeftSecs = 0;

    /*
    * Explicitly separating the calculation for readability
    * Adding 1 second to each work and break duration to account for the transition second
    */
    switch (_currentMode) {
      case TimerMode.workTime:
        totalTimeLeftSecs =
            _remainingSecondsSession +
            ((appState.workDuration + 1) * (numSessionsLeft - 1)) +
            ((appState.breakDuration + 1) * (numSessionsLeft - 1));
        break;
      case TimerMode.breakTime:
        totalTimeLeftSecs =
            _remainingSecondsSession +
            ((appState.workDuration + 1) * numSessionsLeft) +
            ((appState.breakDuration + 1) * (numSessionsLeft - 1));
        break;
    }

    return totalTimeLeftSecs;
  }

  String formatTime(DateTime time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}";
  }

  String get timerText {
    final minutes = (_remainingSecondsSession ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSecondsSession % 60).toString().padLeft(2, '0');
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
        ? ElevatedButton(
            onPressed: pauseTimer,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(Icons.pause, color: Colors.white, size: 32),
          )
        : ElevatedButton(
            onPressed: startTimer,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
          );

    DateTime expectedFinishTime = DateTime.now().add(
      Duration(seconds: calculateTotalTimeLeftInSeconds()),
    );

    double progress =
        _remainingSecondsSession /
        (_currentMode == TimerMode.workTime
            ? appState.workDuration
            : appState.breakDuration);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBar(height: 50, color: Color(0xFF4AA5C1)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Session ${appState.numSessionsTotal + 1 - numSessionsLeft} of ${appState.numSessionsTotal}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentMode == TimerMode.workTime
                                ? const Color(0xFF4AA5C1)
                                : const Color(0xFFFAF8F4),
                          ),
                        ),
                      ),
                      Text(
                        timerText,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          //AN add colour for break time here.
                          color: _currentMode == TimerMode.workTime
                              ? Color(0xFF4AA5C1)
                              : Color(0xFFFAF8F4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _currentMode == TimerMode.workTime
                      ? 'Focus Time'
                      : 'Break Time',
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentMode == TimerMode.workTime
                        ? Color(0xFF4AA5C1)
                        : Color(0xFFFAF8F4),
                  ),
                ),
                //SizedBox(height: 10),
                Text(
                  "Wrap up at ${formatTime(expectedFinishTime)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentMode == TimerMode.workTime
                        ? Color(0xFF4AA5C1)
                        : Color(0xFFFAF8F4),
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: resetCurrentTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 24), // Space between buttons
                    playPauseButton,
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('Back to Setup'),
                ),
                SizedBox(height: 40),
                Lottie.asset(
                  'assets/pathtree.json',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
        ],
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
