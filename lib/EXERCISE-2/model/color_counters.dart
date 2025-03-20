
import 'package:flutter/material.dart';

class ColorCounters extends ChangeNotifier{
  int redTapCount = 0;
  int blueTapCount = 0;
  int currentIndex = 0;

  void incrementRedTapCount() {
      redTapCount++;
      notifyListeners();
  }

  void incrementBlueTapCount() {
      blueTapCount++;
      notifyListeners();

  }
  void updateIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

}
