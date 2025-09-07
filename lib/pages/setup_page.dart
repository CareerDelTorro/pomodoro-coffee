import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_coffee/app_state.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Set Work Duration (minutes)'),
            Slider(
              min: 10,
              max: 60,
              divisions: 10,
              value: appState.workDuration.toDouble(),
              onChanged: (newValue) {
                appState.setWorkDuration(newValue.toInt());
              },
            ),
            SizedBox(height: 20),
            Text('Work Duration: ${appState.workDuration} minutes'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/session'),
              child: Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}
