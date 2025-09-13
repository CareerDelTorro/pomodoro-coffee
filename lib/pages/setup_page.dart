import 'package:flutter/material.dart';
import 'package:pomodoro_coffee/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_coffee/app_state.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBar(
            height: 120,
            color: const Color(0xFF4AA5C1),
            text: 'Pomodoro Coffee',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Focus Duration: ${appState.workDuration} minutes'),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTickMarkColor: Theme.of(
                      context,
                    ).colorScheme.secondary, // Active dots
                    inactiveTickMarkColor: const Color.fromARGB(
                      255,
                      220,
                      220,
                      220,
                    ), // Inactive dots
                  ),
                  child: Slider(
                    min: 10,
                    max: 60,
                    divisions: 10,
                    value: appState.workDuration.toDouble(),
                    onChanged: (newValue) {
                      appState.setWorkDuration(newValue.toInt());
                    },
                    inactiveColor: Color.fromARGB(
                      255,
                      238,
                      242,
                      244,
                    ), // <-- Add this line
                  ),
                ),
                SizedBox(height: 20),

                Text('Break Duration: ${appState.breakDuration} minutes'),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTickMarkColor: Theme.of(
                      context,
                    ).colorScheme.secondary, // Active dots
                    inactiveTickMarkColor: const Color.fromARGB(
                      255,
                      220,
                      220,
                      220,
                    ), // Inactive dots
                  ),
                  child: Slider(
                    min: 5,
                    max: 30,
                    divisions: 5,
                    value: appState.breakDuration.toDouble(),
                    onChanged: (newValue) {
                      appState.setBreakDuration(newValue.toInt());
                    },
                    inactiveColor: Color.fromARGB(255, 238, 242, 244),
                  ),
                ),
                SizedBox(height: 20),
                Text('Number of Sessions:'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Lower value = less round
                    ),
                  ),
                  child: Text("Begin"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
