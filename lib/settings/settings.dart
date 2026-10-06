import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_checkbox/grouped_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:EuroClass_ATS/model/settingmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_language.dart';
import '../app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final SettingModel model;
  final List<String> audioList;
  const SettingsPage({super.key, required this.model, required this.audioList});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> allItemList = [
    'Orange',
    'Blue',
    'Yellow',
    'Green',
    'Red',
    'Pink',
    "Purple",
    "White"
  ];
  List<String> checkedItemList = [
    'Orange',
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    "Red",
    "White"
  ];
  bool customBgColor = false;
  String _pickedColor = "None";
  String _pickedSound = "Beep";
  PersistentBottomSheetController? _controller;
  PersistentBottomSheetController? _controllerSound;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences? sharedPreferences;
  late List<String> audioList;
  List<String> checkedAudio = [];

  @override
  void initState() {
    audioList = widget.audioList;
    if (widget.model.randomBackgroundColor) {
      _pickedColor = "ALL";
      checkedItemList.clear();
      widget.model.selectedColors?.forEach((element) {
        checkedItemList.add(allItemList[element]);
      });
    } else {
      _pickedColor = "None";
    }
    if (widget.model.playSound) {
      _pickedSound = "Custom Sound";
      checkedAudio.clear();
      widget.model.selectedLangIndex?.forEach((element) {
        checkedAudio.add(audioList[element]);
      });
    } else {
      checkedAudio.addAll(audioList);
      _pickedSound = "Beep";
    }
    super.initState();

    SharedPreferences.getInstance().then((value) => sharedPreferences = value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return buildHome(context);
  }

  Widget buildSettingTile({required String title, required String subTitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Text(
                title,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 24),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.0),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    subTitle,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 24),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20.0,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingSwitchButton(
      String title, Function(bool) onChange, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Text(
                title,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 24),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(12.0),
              alignment: Alignment.centerRight,
              child: CupertinoSwitch(
                onChanged: onChange,
                value: value,
                activeTrackColor: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionSelector({
    required List<String> labels,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: List.generate(values.length, (index) {
        return ButtonSegment<String>(
          value: values[index],
          label: Text(labels[index]),
        );
      }),
      selected: {selectedValue},
      onSelectionChanged: (selection) => onSelected(selection.first),
    );
  }

  Widget buildHome(BuildContext context) {
    var appLanguageBuild = Provider.of<AppLanguage>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
        if (widget.model.selectedLangIndex != null) {
          await prefs.setStringList(
              "sounds",
              widget.model.selectedLangIndex!
                  .map((e) => e.toString())
                  .toList());
        }
        if (widget.model.selectedColors != null) {
          await prefs.setStringList(
              "colors",
              widget.model.selectedColors!.map((e) => e.toString()).toList());
        }
        if (context.mounted) {
          Navigator.of(context).pop(widget.model);
        }
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).translate("settings"),
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 24),
            ),
            centerTitle: true,
          ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        final englishController = FixedExtentScrollController(
                            initialItem: widget.model.defaultLang.languageCode ==
                                    "en"
                                ? 0
                                : 1);
                        showCupertinoModalPopup(
                            context: context,
                            builder: (c) => Container(
                                  height: 300,
                                  child: CupertinoPicker.builder(
                                      itemExtent: 50.0,
                                      scrollController: englishController,
                                      childCount: 2,
                                      backgroundColor: Colors.white,
                                      onSelectedItemChanged: (item) {
                                        setState(() {
                                          widget.model.defaultLang = item == 0
                                              ? Locale("en")
                                              : Locale("fr");
                                        });
                                      },
                                      itemBuilder: (c, i) => Container(
                                          child: Text((i == 0
                                                  ? AppLocalizations.of(context)
                                                      .translate("english")
                                                  : AppLocalizations.of(context)
                                                      .translate("french"))
                                              .toString()))),
                                )).whenComplete(() async {
                          await appLanguageBuild
                              .changeLanguage(widget.model.defaultLang);
                        });
                      },
                      child: buildSettingTile(
                          title: AppLocalizations.of(context)
                              .translate("language"),
                          subTitle: widget.model.defaultLang.languageCode == "en"
                              ? AppLocalizations.of(context).translate("english")
                              : AppLocalizations.of(context)
                                  .translate("french"))),
                  GestureDetector(
                      onTap: () {
                        _controller =
                            _scaffoldKey.currentState!.showBottomSheet((context) =>
                                Material(
                                  child: Material(
                                    elevation: 10.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0))),
                                    child: Container(
                                      height: 400,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate("chooseBg"),
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextButton.icon(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: Icon(Icons.close),
                                                      label: Text(""))
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  top: 16.0,
                                                  bottom: 16.0,
                                                  right: 0.0,
                                                  left: 16.0),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: _optionSelector(
                                                  labels: [
                                                    AppLocalizations.of(context)
                                                        .translate("none"),
                                                    AppLocalizations.of(context)
                                                        .translate("all"),
                                                  ],
                                                  values: const [
                                                    "None",
                                                    "Random Color",
                                                  ],
                                                  selectedValue: widget.model
                                                          .randomBackgroundColor
                                                      ? "Random Color"
                                                      : "None",
                                                  onSelected: (value) {
                                                    _controller?.setState?.call(() {
                                                      if (value ==
                                                          "Random Color") {
                                                        widget.model
                                                                .randomBackgroundColor =
                                                            true;
                                                        if (widget.model
                                                                .selectedColors ==
                                                            null) {
                                                          widget.model
                                                                  .selectedColors =
                                                              [
                                                            0,
                                                            1,
                                                            2,
                                                            3,
                                                            4,
                                                            5,
                                                            6
                                                          ];
                                                        }
                                                      } else {
                                                        widget.model
                                                                .randomBackgroundColor =
                                                            false;
                                                      }
                                                      setState(() {
                                                        _pickedColor = value;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            GroupedCheckbox<String>(
                                                itemList: allItemList,
                                                checkedItemList:
                                                    _pickedColor == "None"
                                                        ? []
                                                        : checkedItemList,
                                                disabled: _pickedColor == "None"
                                                    ? allItemList
                                                    : [],
                                                onChanged: (itemList) {
                                                  _controller?.setState?.call(() {
                                                    var items = itemList ??
                                                        <String>[];
                                                    var newList = <int>[];
                                                    if (items.contains("Orange")) {
                                                      newList.add(0);
                                                    }
                                                    if (items.contains("Blue")) {
                                                      newList.add(1);
                                                    }
                                                    if (items.contains("Yellow")) {
                                                      newList.add(2);
                                                    }
                                                    if (items.contains("Green")) {
                                                      newList.add(3);
                                                    }
                                                    if (items.contains("Red")) {
                                                      newList.add(4);
                                                    }
                                                    if (items.contains("Pink")) {
                                                      newList.add(5);
                                                    }
                                                    if (items.contains("Purple")) {
                                                      newList.add(6);
                                                    }
                                                    if (items.contains("White")) {
                                                      newList.add(7);
                                                    }
                                                    widget.model.selectedColors =
                                                        newList;
                                                    if (_pickedColor != 'None') {
                                                      checkedItemList =
                                                          List<String>.from(
                                                              items);
                                                    }
                                                    print(
                                                        'SELECTED ITEM LIST $itemList');
                                                  });
                                                },
                                                orientation: CheckboxOrientation
                                                    .vertical,
                                                checkColor: Colors.white,
                                                activeColor: Colors.blue,
                                                itemWidgetBuilder: (item) =>
                                                    Text(item))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                      },
                      child: buildSettingTile(
                          title:
                              AppLocalizations.of(context).translate("bgColor"),
                          subTitle: widget.model.randomBackgroundColor
                              ? AppLocalizations.of(context)
                                  .translate("randomColor")
                              : AppLocalizations.of(context).translate("none"))),
                  GestureDetector(
                    onTap: () {
                      final fgTextController = FixedExtentScrollController(
                          initialItem:
                              widget.model.randomForegroundText ? 0 : 1);
                      showCupertinoModalPopup(
                          context: context,
                          builder: (c) => Container(
                                height: 300,
                                child: CupertinoPicker.builder(
                                    itemExtent: 50.0,
                                    childCount: 2,
                                    scrollController: fgTextController,
                                    backgroundColor: Colors.white,
                                    onSelectedItemChanged: (item) {
                                      setState(() {
                                        widget.model.randomForegroundText =
                                            item == 0;
                                      });
                                    },
                                    itemBuilder: (c, i) => Container(
                                        child: Text((i == 0
                                                ? AppLocalizations.of(context)
                                                    .translate("randomNumber")
                                                : AppLocalizations.of(context)
                                                    .translate("none"))
                                            .toString()))),
                              ));
                    },
                    child: buildSettingTile(
                        title:
                            AppLocalizations.of(context).translate("fgColor"),
                        subTitle: widget.model.randomForegroundText
                            ? AppLocalizations.of(context)
                                .translate("randomNumber")
                            : AppLocalizations.of(context).translate("none")),
                  ),
                  GestureDetector(
                      onTap: () {},
                      child: buildSettingTile(
                          title: AppLocalizations.of(context)
                              .translate("delaySec"),
                          subTitle: widget.model.delayInSeconds.toString())),
                  Slider(
                    max: 60,
                    min: 0,
                    onChanged: (value) {
                      setState(() {
                        widget.model.delayInSeconds = value.toInt();
                      });
                    },
                    value: widget.model.delayInSeconds.toDouble(),
                  ),
                  buildSettingTile(
                      title:
                          AppLocalizations.of(context).translate("maxNumber"),
                      subTitle:
                          "${widget.model.maxRangeValue.start.floor()}-${widget.model.maxRangeValue.end.floor()}"),
                  RangeSlider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    values: widget.model.maxRangeValue,
                    labels: RangeLabels(
                      widget.model.maxRangeValue.start.toStringAsFixed(1),
                      widget.model.maxRangeValue.end.toStringAsFixed(1),
                    ),
                    onChanged: (values) {
                      setState(() {
                        widget.model.maxRangeValue = values;
                      });
                    },
                  ),
                  GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (c) => Container(
                                  height: 300,
                                  child: CupertinoPicker.builder(
                                      itemExtent: 50.0,
                                      childCount: 600,
                                      backgroundColor: Colors.white,
                                      onSelectedItemChanged: (item) {
                                        setState(() {
                                          widget.model.runForSeconds = item * 10;
                                        });
                                      },
                                      itemBuilder: (c, i) => Container(
                                          child: Text((i * 10).toString()))),
                                ));
                      },
                      child: buildSettingTile(
                          title: AppLocalizations.of(context)
                              .translate("runForSec"),
                          subTitle: widget.model.runForSeconds.toString())),
                  GestureDetector(
                      onTap: () {
                        _controllerSound = _scaffoldKey.currentState!
                            .showBottomSheet((context) => Material(
                                  child: Material(
                                    elevation: 10.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            topRight: Radius.circular(30.0))),
                                    child: Container(
                                      height: 400,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate("chooseSound"),
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextButton.icon(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: Icon(Icons.close),
                                                      label: Text(""))
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  top: 16.0,
                                                  bottom: 16.0,
                                                  right: 0.0,
                                                  left: 16.0),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: _optionSelector(
                                                  labels: [
                                                    AppLocalizations.of(context)
                                                        .translate("none"),
                                                    AppLocalizations.of(context)
                                                        .translate("all"),
                                                  ],
                                                  values: const [
                                                    "Beep",
                                                    "Custom Sound",
                                                  ],
                                                  selectedValue:
                                                      widget.model.playSound
                                                          ? "Custom Sound"
                                                          : "Beep",
                                                  onSelected: (value) {
                                                    _controllerSound
                                                        ?.setState?.call(() {
                                                      if (value == "Beep") {
                                                        widget.model.playSound =
                                                            false;
                                                      } else {
                                                        widget.model
                                                                .selectedLangIndex =
                                                            List.generate(
                                                                9,
                                                                (index) =>
                                                                    index);
                                                        widget.model.playSound =
                                                            true;
                                                      }
                                                      setState(() {
                                                        _pickedSound = value;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            GroupedCheckbox<String>(
                                                itemList: audioList,
                                                checkedItemList:
                                                    _pickedSound == "Beep"
                                                        ? []
                                                        : checkedAudio,
                                                disabled: _pickedSound == "Beep"
                                                    ? checkedAudio
                                                    : [],
                                                onChanged: (itemList) async {
                                                  print(
                                                      'SELECTED ITEM LIST $itemList');
                                                  var items =
                                                      itemList ?? <String>[];
                                                  var newList = <int>[];
                                                  _controllerSound
                                                      ?.setState?.call(() {
                                                    if (items.contains(
                                                        audioList[0])) {
                                                      newList.add(0);
                                                    }
                                                    if (items.contains(
                                                        audioList[1])) {
                                                      newList.add(1);
                                                    }
                                                    if (items.contains(
                                                        audioList[2])) {
                                                      newList.add(2);
                                                    }
                                                    if (items.contains(
                                                        audioList[3])) {
                                                      newList.add(3);
                                                    }
                                                    if (items.contains(
                                                        audioList[4])) {
                                                      newList.add(4);
                                                    }
                                                    if (items.contains(
                                                        audioList[5])) {
                                                      newList.add(5);
                                                    }
                                                    if (items.contains(
                                                        audioList[6])) {
                                                      newList.add(6);
                                                    }
                                                    if (items.contains(
                                                        audioList[7])) {
                                                      newList.add(7);
                                                    }
                                                    if (items.contains(
                                                        audioList[8])) {
                                                      newList.add(8);
                                                    }

                                                    if (_pickedSound != 'Beep') {
                                                      checkedAudio =
                                                          List<String>.from(
                                                              items);
                                                    }
                                                    print(
                                                        'SELECTED ITEM LIST $itemList');
                                                  });
                                                  setState(() {
                                                    widget.model
                                                            .selectedLangIndex =
                                                        newList;
                                                  });
                                                },
                                                orientation: CheckboxOrientation
                                                    .vertical,
                                                checkColor: Colors.white,
                                                activeColor: Colors.blue,
                                                itemWidgetBuilder: (item) =>
                                                    Text(item))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                      },
                      child: buildSettingTile(
                          title:
                              AppLocalizations.of(context).translate("sound"),
                          subTitle: widget.model.playSound
                              ? AppLocalizations.of(context)
                                  .translate("customSound")
                              : AppLocalizations.of(context).translate('none'))),
                  buildSettingSwitchButton(
                      AppLocalizations.of(context).translate("beepOne"),
                      (value) {
                    setState(() {
                      widget.model.enableBeep = value;
                    });
                  }, widget.model.enableBeep),
                ],
              ),
            ),
          )),
    );
  }
}
