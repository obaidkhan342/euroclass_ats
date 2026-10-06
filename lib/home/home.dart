import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EuroClass_ATS/app_localizations.dart';
import 'package:EuroClass_ATS/model/settingmodel.dart';
import 'package:EuroClass_ATS/settings/settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController? _animationController;
  int number = Random(0).nextInt(99);
  Timer? timer;
  IconData playPause = Icons.play_arrow;
  SettingModel settingModel = SettingModel();
  Color randomColor = Colors.blue;
  int timeLeft = 0;
  List<int> numberList = [];
  List<String> audioList = [];
  List<Color> color = [
    Colors.orange,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.white
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();
  double buttonSize = 24;
  var soundSize = 8;
  List<int> radndom = [];
  String actionText = "Action";
  SharedPreferences? sharedPreferences;

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  @override
  void initState() {
    super.initState();
    loadSettingModel().whenComplete(() {
      initialState();
      if (settingModel.playSound) {
        SharedPreferences.getInstance().then((value) {
          sharedPreferences = value;
          if (settingModel.playSound) {
            final sounds = value.getStringList("sounds");
            if (sounds != null) {
              settingModel.selectedLangIndex =
                  sounds.map((e) => int.tryParse(e)).whereType<int>().toList();
            }
          }
          List<int> list = [];
          if (settingModel.selectedLangIndex != null) {
            list.addAll(settingModel.selectedLangIndex!);
          }
          radndom = list;
        });
      } else {
        radndom = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      }
    });
  }

  changeNumberOrColor() async {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    numberList.clear();
    print(settingModel.maxRangeValue.start.floor());

    for (int i = settingModel.maxRangeValue.start.floor();
        i <= settingModel.maxRangeValue.end.floor();
        i++) {
      numberList.add(settingModel.maxRangeValue.start.floor() + i);
    }

    timer = Timer.periodic(Duration(seconds: settingModel.delayInSeconds),
        (time) {
      timeLeft = timeLeft + 1;
      if (settingModel.playSound || settingModel.enableBeep) playSound();
      setState(() {
        if (time.tick == settingModel.runForSeconds ||
            timeLeft == settingModel.runForSeconds) {
          timer?.cancel();
          playPause = Icons.play_arrow;
          initAnimation(0.0);
          _animationController?.reset();
        }
        if (settingModel.randomBackgroundColor) {
          randomColor = generateRandomColor();
        }
        if (settingModel.randomForegroundText) {
          number = generateRandomNumber(numberList);
        }
      });
    });
  }

  initialState() async {
    timeLeft = 0;
    if (_animationController != null) {
      _animationController!.reset();
    }
    if (!settingModel.randomBackgroundColor) {
      randomColor = Colors.white;
    } else {
      if (sharedPreferences == null) {
        sharedPreferences = await SharedPreferences.getInstance();
      }
      randomColor = generateRandomColor();
    }
    initAnimation(0.0);
    _animationController!.addListener(() {
      setState(() {});
    });
    timer = null;
    setState(() {
      playPause = Icons.play_arrow;
    });
  }

  Color generateRandomColor() {
    final stored = sharedPreferences?.getStringList("colors");
    if (stored != null) {
      settingModel.selectedColors =
          stored.map((e) => int.tryParse(e)).whereType<int>().toList();
    }
    if (settingModel.selectedColors == null) {
      settingModel.selectedColors = [0, 1, 2, 3, 4, 5, 6, 7];
    }
    List<Color> myColors = [];
    settingModel.selectedColors!.forEach((element) {
      myColors.add(color[element]);
    });

    if (myColors.isEmpty) return Colors.blue;
    var choiece = myColors[Random().nextInt(myColors.length)];
    print(choiece);
    return choiece;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    buttonSize = isTablet
        ? MediaQuery.of(context).size.width / 30
        : MediaQuery.of(context).size.width / 20;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "EuroClass",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 24),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.settings,
                size: buttonSize,
                color: Colors.white,
              ),
              onPressed: () async {
                timer?.cancel();
                final result = await Navigator.of(context).push<SettingModel>(
                    CupertinoPageRoute(
                        builder: (c) => SettingsPage(
                              model: settingModel,
                              audioList: audioList,
                            )));
                if (result == null) return;
                await saveModel(result);
                initialState();
                setState(() {
                  settingModel = result;
                });
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: isTablet
                              ? MediaQuery.of(context).size.height / 1.5
                              : MediaQuery.of(context).size.height / 2.0,
                          margin: EdgeInsets.all(15.0),
                          child: CircularPercentIndicator(
                            radius: (isTablet
                                    ? MediaQuery.of(context).size.height / 1.8
                                    : MediaQuery.of(context).size.height / 2.3) /
                                2,
                            lineWidth: MediaQuery.of(context).size.width / 32,
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: _animationController?.value ?? 0,
                            center: Visibility(
                              visible: settingModel.randomForegroundText,
                              child: Text(
                                number.toString(),
                                style: TextStyle(
                                  fontSize: buttonSize * 7,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(-1.5, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        offset: Offset(1.5, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        offset: Offset(1.5, 1.5),
                                        color: Colors.black),
                                    Shadow(
                                        offset: Offset(-1.5, 1.5),
                                        color: Colors.black),
                                  ],
                                  fontWeight: FontWeight.bold,
                                  color: settingModel.randomBackgroundColor
                                      ? Colors.white
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            progressColor: Colors.blue.shade900,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: randomColor),
                        ),
                        Text(
                          actionText,
                          style: TextStyle(
                              fontSize: buttonSize, color: Colors.black),
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade900),
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.height /
                                          20,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        timer?.cancel();
                                        initialState();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade900),
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Icon(
                                      playPause,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.height /
                                          20,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (timer == null) {
                                          _animationController?.forward();
                                          playPause = Icons.pause;
                                          changeNumberOrColor();
                                          print("timer null");
                                        } else if (timer!.isActive) {
                                          _animationController?.stop(
                                              canceled: false);
                                          timer!.cancel();
                                          print("timer cancel");
                                          playPause = Icons.play_arrow;
                                        } else {
                                          _animationController?.forward();
                                          playPause = Icons.pause;
                                          print("restart");
                                          changeNumberOrColor();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade900),
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.height /
                                          20,
                                    ),
                                    onTap: () {
                                      if (settingModel.randomForegroundText) {
                                        number =
                                            generateRandomNumber(numberList);
                                      }
                                      if (settingModel.randomBackgroundColor) {
                                        randomColor = generateRandomColor();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 60.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
                top: MediaQuery.of(context).size.height / 1.8,
                child: Container(
                  child: Column(
                    children: <Widget>[],
                  ),
                ))
          ],
        ));
  }

  Future<void> playSound() async {
    final String assetPath;
    if (settingModel.enableBeep) {
      assetPath = "asset/audio/beep.mp3";
    } else {
      radndom = List<int>.from(settingModel.selectedLangIndex ?? []);
      radndom.shuffle();
      print("random number is: " + number.toString());
      if (settingModel.selectedLangIndex != null) {
        settingModel.selectedLangIndex!.shuffle();
      }
      var value = settingModel.selectedLangIndex != null
          ? settingModel.selectedLangIndex![0]
          : radndom[0] - 1;
      setState(() {
        actionText = audioList[value];
      });
      var audioFile;
      if (settingModel.playSound) {
        audioFile = settingModel.defaultLang.languageCode +
            "/" +
            (value + 1).toString();
      } else {
        audioFile = settingModel.defaultLang.languageCode +
            "/" +
            radndom[value].toString();
      }
      assetPath = "asset/audio/$audioFile.mp3";
    }

    final data = await rootBundle.load(assetPath);
    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    ));
  }

  int generateRandomNumber(List<int> list) {
    list.shuffle();
    var randomItem = (list.toList()..shuffle()).first;
    return randomItem;
  }

  Future<void> loadSettingModel() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey("setting")) {
      settingModel = SettingModel();
    } else {
      final saved = sharedPreferences.getString("setting");
      if (saved == null) {
        settingModel = SettingModel();
      } else {
        settingModel = SettingModel.fromJson(jsonDecode(saved));
      }
    }
  }

  saveModel(SettingModel model) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("setting", jsonEncode(model.toJson()));
    if (model.selectedLangIndex != null) {
      await sharedPreferences.setStringList("sounds",
          model.selectedLangIndex!.map((e) => e.toString()).toList());
    }
    if (model.selectedColors != null) {
      settingModel.selectedColors = model.selectedColors;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioList = AppLocalizations.of(context)
        .translate("audio")
        .replaceAll("[", "")
        .replaceAll("]", "")
        .split(",");
  }

  void initAnimation(double d) {
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                settingModel.runForSeconds * settingModel.delayInSeconds),
        lowerBound: d);
  }
}
