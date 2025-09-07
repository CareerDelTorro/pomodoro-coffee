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
    primaryColor: Color(0xFF3630A1), // Replace with your hex color
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Color(0xFF3630A1), // Your custom color
      secondary: Color(0xFFFAF8F4), // Optional: accent color
    ),
    // ...other theme settings...
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
