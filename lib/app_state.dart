import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int workDuration = 25;
  int breakDuration = 5;
  int numSessionsTotal = 4;

  void setWorkDuration(int value) {
    workDuration = value;
    notifyListeners();
  }

  void setBreakDuration(int value) {
    breakDuration = value;
    notifyListeners();
  }

  void setNumSessions(int value) {
    numSessionsTotal = value;
    notifyListeners();
  }
}
