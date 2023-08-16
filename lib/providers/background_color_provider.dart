import 'package:flutter/material.dart';

class BackgroundColorProvider extends ChangeNotifier {
  Color mainColor = Colors.white;

  void changeThemeColor(Color color) {
    mainColor = color;
    notifyListeners();
  }

}