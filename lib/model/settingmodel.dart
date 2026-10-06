import 'package:flutter/material.dart';

class SettingModel {
  int delayInSeconds;
  RangeValues maxRangeValue;
  int runForSeconds;
  bool randomForegroundText;
  bool randomBackgroundColor;
  bool isEnglishLang;
  bool enableBeep;
  bool playSound;
  Locale defaultLang;
  List<int>? selectedColors;
  List<int>? selectedLangIndex;

  SettingModel({
    this.delayInSeconds = 1,
    this.enableBeep = true,
    this.defaultLang = const Locale("en"),
    this.isEnglishLang = true,
    this.playSound = true,
    this.randomForegroundText = true,
    this.randomBackgroundColor = false,
    this.maxRangeValue = const RangeValues(0, 99),
    this.selectedColors,
    this.selectedLangIndex,
    this.runForSeconds = 60,
  });

  factory SettingModel.fromJson(Map<String, dynamic> map) {
    return SettingModel(
      defaultLang: Locale(map["defaultLang"]),
      delayInSeconds: map["delayInSeconds"],
      enableBeep: map["enableBeep"],
      isEnglishLang: map["isEnglishLang"],
      maxRangeValue: RangeValues(double.parse(map["minRangeValue"]),
          double.parse(map["maxRangeValue"])),
      playSound: map["playSound"],
      randomBackgroundColor: map["randomBackgroundColor"],
      randomForegroundText: map["randomForegroundText"],
      runForSeconds: map["runForSeconds"],
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultLang': defaultLang.languageCode,
        'playSound': playSound,
        'maxRangeValue': maxRangeValue.end.toString(),
        'minRangeValue': maxRangeValue.start.toString(),
        'isEnglishLang': isEnglishLang,
        'enableBeep': enableBeep,
        'delayInSeconds': delayInSeconds,
        'runForSeconds': runForSeconds,
        'randomForegroundText': randomForegroundText,
        'randomBackgroundColor': randomBackgroundColor,
      };
}
