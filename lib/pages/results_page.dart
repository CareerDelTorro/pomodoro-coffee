import 'package:flutter/material.dart';
import 'package:pomodoro_coffee/app_state.dart';
import 'package:pomodoro_coffee/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use appState to access shared state
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBar(height: 120, color: Colors.deepPurple, text: 'Complete'),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Congratulations! You completed ${Provider.of<AppState>(context, listen: false).numSessionsTotal} sessions.',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('Back to Setup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
