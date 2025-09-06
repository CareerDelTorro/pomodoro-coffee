import 'package:flutter/material.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int workDuration = 25;
  int breakDuration = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Set Work Duration (minutes)'),
            Slider(
              min: 10,
              max: 60,
              divisions: 10,
              value: workDuration.toDouble(),
              onChanged: (newValue) => {
                workDuration = newValue.toInt(),
                setState(() {}),
              },
            ),
            SizedBox(height: 20),
            Text('Work Duration: $workDuration minutes'),
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
