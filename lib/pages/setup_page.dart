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
            Text('Set Work Duration (minutes): ${appState.workDuration}'),
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

            Text('Set Break Duration (minutes): ${appState.breakDuration}'),
            Slider(
              min: 5,
              max: 30,
              divisions: 5,
              value: appState.breakDuration.toDouble(),
              onChanged: (newValue) {
                appState.setBreakDuration(newValue.toInt());
              },
            ),
            SizedBox(height: 20),
            Text('Set Number of Sessions:'),
            DropdownButton(
              items: List.generate(5, (index) => index + 1)
                  .map(
                    (numSessions) => DropdownMenuItem(
                      value: numSessions,
                      child: Text(numSessions.toString()),
                    ),
                  )
                  .toList(),
              value: appState.numSessionsTotal,
              onChanged: (newValue) {
                if (newValue != null) {
                  appState.setNumSessions(newValue);
                }
              },
            ),
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
