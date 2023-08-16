import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale locale = Locale('en', '');

  void changeLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }

}