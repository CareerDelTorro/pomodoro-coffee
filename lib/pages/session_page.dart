import 'dart:async';
import 'dart:math'; // <-- added for atan2, pi
import 'package:audioplayers/audioplayers.dart';
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

class SessionPageState extends State<SessionPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSecondsSession = 0;
  TimerMode _currentMode = TimerMode.workTime;
  int numSessionsLeft = 0;
  Color backgroundColor = Colors.red;
  bool isRunning = false;
  late AnimationController _lottieController;
  bool isLottieReady = false;
  bool isPlayHovered = false;
  bool isResetHovered = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  void setTimer(int durationMin) {
    setState(() {
      _remainingSecondsSession = durationMin * 60;
    });
  }

  void startTimer() {
    _timer?.cancel();

    setState(() {
      isRunning = true;
    });

    if (isLottieReady) {
      _lottieController.repeat(); // resume animation
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // account for 1s delay in the audio file
      if (_remainingSecondsSession == 31) {
        _audioPlayer.play(AssetSource('long-warning.wav'));
      }
      if (_remainingSecondsSession == 10) {
        _audioPlayer.play(AssetSource('slow-countdown.wav'));
      }
      if (_remainingSecondsSession == 2) {
        _audioPlayer.play(AssetSource('fast-countdown.wav'));
      }
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
    _audioPlayer.stop();
    _lottieController.stop(); // pause animation
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
      // _audioPlayer.stop(); might be anticlimactic
      Navigator.pushNamed(context, '/results');
    }
  }

  void switchMode(TimerMode mode) {
    final appState = Provider.of<AppState>(context, listen: false);

    _audioPlayer.play(AssetSource('switch-warning.wav'));

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
            ((appState.workDuration * 60 + 1) * (numSessionsLeft - 1)) +
            ((appState.breakDuration * 60 + 1) * (numSessionsLeft - 1));
        break;
      case TimerMode.breakTime:
        totalTimeLeftSecs =
            _remainingSecondsSession +
            ((appState.workDuration * 60 + 1) * numSessionsLeft) +
            ((appState.breakDuration * 60 + 1) * (numSessionsLeft - 1));
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

    _lottieController = AnimationController(vsync: this);

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

    Widget playPauseButton = MouseRegion(
      onEnter: (_) => setState(() => isPlayHovered = true),
      onExit: (_) => setState(() => isPlayHovered = false),
      child: ElevatedButton(
        onPressed: isRunning ? pauseTimer : startTimer,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: isPlayHovered
              ? Theme.of(context).colorScheme.secondary.withAlpha(
                  (0.8 * 255).toInt(),
                ) // 0.8 opacity
              : Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );

    DateTime expectedFinishTime = DateTime.now().add(
      Duration(seconds: calculateTotalTimeLeftInSeconds()),
    );

    double progress =
        _remainingSecondsSession /
        (_currentMode == TimerMode.workTime
            ? appState.workDuration * 60
            : appState.breakDuration * 60);

    // <-- move the declaration here (before the widget tree)
    final double timerSize = MediaQuery.of(context).size.width * 0.6;

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
                // replace existing SizedBox timer with this responsive, interactive one
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _updateTimerFromLocalPosition(
                    details.localPosition,
                    timerSize,
                  ),
                  onPanStart: (details) => _updateTimerFromLocalPosition(
                    details.localPosition,
                    timerSize,
                  ),
                  onPanUpdate: (details) => _updateTimerFromLocalPosition(
                    details.localPosition,
                    timerSize,
                  ),
                  child: SizedBox(
                    width: timerSize,
                    height: timerSize,
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
                            color: _currentMode == TimerMode.workTime
                                ? Color(0xFF4AA5C1)
                                : Color(0xFFFAF8F4),
                          ),
                        ),
                      ],
                    ),
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
                    MouseRegion(
                      onEnter: (_) => setState(() => isResetHovered = true),
                      onExit: (_) => setState(() => isResetHovered = false),
                      child: ElevatedButton(
                        onPressed: resetCurrentTimer,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: isResetHovered
                              ? Theme.of(context).colorScheme.secondary
                                    .withAlpha((0.8 * 255).toInt())
                              // possibly use this code:
                              // ? const Color(0xFF3560A1).withAlpha((0.8 * 255).toInt())
                              : Theme.of(context).colorScheme.primary,
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(width: 24), // Space between buttons
                    playPauseButton,
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('Back to Setup'),
                ),
                SizedBox(height: 40),
                Lottie.asset(
                  'assets/pathtree.json',
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                    isLottieReady = true;
                    if (isRunning) {
                      _lottieController.repeat();
                    }
                  },
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
    _lottieController.dispose();
    _audioPlayer.stop();
    super.dispose();
  }

  // Call this with a local position inside the circular timer widget.
  void _updateTimerFromLocalPosition(Offset localPos, double widgetSize) {
    final center = Offset(widgetSize / 2, widgetSize / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    // angle from +x axis, counter-clockwise, range -pi..pi
    final angle = atan2(dy, dx);

    // shift so 0 is at top and increase clockwise
    double angleFromTop = angle + pi / 2;
    if (angleFromTop < 0) angleFromTop += 2 * pi;

    final fraction = angleFromTop / (2 * pi); // 0..1 around the circle

    final appState = Provider.of<AppState>(context, listen: false);
    final totalSeconds =
        (_currentMode == TimerMode.workTime
            ? appState.workDuration
            : appState.breakDuration) *
        60;

    // map fraction -> remaining seconds (top = full duration)
    // Inverted mapping: top = 0, clockwise increases remaining
    final newRemaining = (fraction * totalSeconds).round().clamp(
      0,
      totalSeconds,
    );

    setState(() {
      _remainingSecondsSession = newRemaining;
    });
  }
}

enum TimerMode { workTime, breakTime }
