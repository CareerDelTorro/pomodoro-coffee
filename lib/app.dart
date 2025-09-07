import 'package:flutter/material.dart';
import 'package:pomodoro_coffee/app_state.dart';
import 'package:pomodoro_coffee/pages/results_page.dart';
import 'package:pomodoro_coffee/pages/session_page.dart';
import 'package:pomodoro_coffee/pages/setup_page.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Pomodoro Coffee',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routes: {
          '/': (context) => SetupPage(),
          '/session': (context) => SessionPage(),
          '/results': (context) => ResultsPage(),
        },
      ),
    );
  }
}
