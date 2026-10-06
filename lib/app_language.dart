import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class AppLanguage extends ChangeNotifier {
  static Locale _appLocale = Locale('en', "EN");
  AppLocalizations localization = AppLocalizations(_appLocale);

  Locale get appLocal => _appLocale;

  Locale get appLocale => _appLocale;

  Future<void> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    var locale = await Devicelocale.currentLocale;
    if (prefs.containsKey("countryCode") &&
        prefs.getString("countryCode") == "FR") {
      _appLocale = Locale("fr", "FR");
    } else if (prefs.containsKey("countryCode") &&
        prefs.getString("countryCode") == "US") {
      _appLocale = Locale("en", "EN");
    } else if ((locale ?? '').contains('fr')) {
      _appLocale = Locale("fr", "FR");
    } else {
      _appLocale = Locale("en", "EN");
    }
    localization = AppLocalizations(_appLocale);
  }

  Future<void> changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    print(_appLocale.languageCode);
    if (_appLocale == type) {
      print("same" + _appLocale.languageCode);
      return;
    }
    if (type == Locale("fr")) {
      _appLocale = Locale("fr", "FR");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', 'FR');
    } else {
      _appLocale = Locale("en", "EN");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }
}
