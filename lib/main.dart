import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telecommande/settingsPage.dart';
import 'package:vibration/vibration.dart';

import 'IconGesture.dart';

void main() {
  runApp(MaterialApp(
    title: 'Telecommande',
    initialRoute: '/',
    routes: {
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/': (context) => const MyApp(),
      '/param': (context) => SettingsPage(),
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String code = "";
  bool disableButtonMode = false;
  bool infoButton = true;
  bool showPad = true;
  bool volUp = false;
  bool volDown = false;
  bool arrowUp = false;
  bool arrowDown = false;
  bool arrowLeft = false;
  bool arrowRight = false;
  final int longArrowDelay = 300;
  final int longVolumeDelay = 20;
  double iconSize = 50.0;
  ThemeMode _themeMode =
      SchedulerBinding.instance.window.platformBrightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark;

  Map buttonIsActive = {
    "vol_inc": true,
    "red": true,
    "up": true,
    "blue": true,
    "prgm_inc": true,
    "vol": true,
    "left": true,
    "OK": true,
    "right": true,
    "prog": true,
    "vol_dec": true,
    "green": true,
    "down": true,
    "yellow": true,
    "prgm_dec": true,
    "1": true,
    "2": true,
    "3": true,
    "4": true,
    "5": true,
    "6": true,
    "7": true,
    "8": true,
    "9": true,
    "0": true,
    "bwd": true,
    "play": true,
    "fwd": true,
    "random": true,
    "rec": true,
    "mute": true,
    "home": true,
    "power": true,
    "lock": false
  };

  Future<void> _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('code')) {
      setState(() {
        code = prefs.getString('code') ?? "erreur";
      });
    }
    if (prefs.containsKey('infoButton')) {
      setState(() {
        infoButton = prefs.getBool('infoButton') ?? true;
      });
    }
    if (prefs.containsKey('showPad')) {
      setState(() {
        showPad = prefs.getBool('showPad') ?? true;
      });
    }
    if (prefs.containsKey('iconSize')) {
      setState(() {
        iconSize = prefs.getDouble('iconSize') ?? 50.0;
      });
    }
    if (prefs.containsKey('themeMode')) {
      setState(() {
        _themeMode = prefs.getString('themeMode') == "dark"
            ? ThemeMode.dark
            : ThemeMode.light;
      });
    }
    if (prefs.containsKey('buttonIsActive')) {
      setState(() {
        buttonIsActive = json.decode(prefs.getString('buttonIsActive')!);
      });
    }
  }

  Future<void> _saveThemeMode(String str) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', str);
  }

  Future<void> _saveButtonIsActive() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('buttonIsActive', json.encode(buttonIsActive));
  }

  void changeButtonActive(String key) {
    if (buttonIsActive[key] != null) {
      if (!buttonIsActive["lock"]!) {
        setState(() {
          buttonIsActive[key] = !buttonIsActive[key]!;
        });
        _saveButtonIsActive();
      } else {
        Fluttertoast.showToast(
            msg: "boutons verrouillés",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.lightBlueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: TextTheme.lerp(
                Typography.blackCupertino, Typography.whiteCupertino, 0.7),
            iconTheme: IconThemeData(color: Colors.grey[500])),
        themeMode: _themeMode,
        home: Scaffold(
            appBar: AppBar(title: const Text("freebox"), actions: [
              IconButton(
                icon: Icon(_themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode_outlined),
                onPressed: () {
                  setState(() {
                    _themeMode = _themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    _saveThemeMode(
                        _themeMode == ThemeMode.dark ? "dark" : "light");
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await _openParam(context);
                },
              )
            ]),
            body: OrientationBuilder(builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return Column(
                    children: showPad
                        ? [
                            remote(iconSize),
                            pad(),
                          ]
                        : [remote(iconSize)]);
              } else {
                return Row(
                    children: showPad
                        ? [
                            SingleChildScrollView(child: remote(iconSize)),
                            pad(),
                          ]
                        : [SingleChildScrollView(child: remote(iconSize))]);
              }
            })));
  }

  Widget remote(iconSize) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: const Icon(Icons.add),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["vol_inc"]!,
                  onPressed: () {
                    sendOrder("vol_inc");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      volUp = true;
                    });
                    Vibration.vibrate(duration: 20);
                    longPress("vol_inc", longVolumeDelay);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      volUp = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.subdirectory_arrow_left_rounded),
                  active: buttonIsActive["red"]!,
                  onPressed: () {
                    sendOrder("red");
                  },
                  onLongPress: () {
                    changeButtonActive("red");
                  },
                  color: Colors.red,
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.arrow_upward),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["up"]!,
                  onPressed: () {
                    sendOrder("up");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      arrowUp = true;
                    });
                    Vibration.vibrate(duration: 20);
                    longPress("up", longArrowDelay);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      arrowUp = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.search),
                  active: buttonIsActive["blue"]!,
                  onPressed: () {
                    sendOrder("blue");
                  },
                  onLongPress: () {
                    changeButtonActive("blue");
                  },
                  color: Colors.blue,
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.add),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["prgm_inc"]!,
                  onPressed: () {
                    sendOrder("prgm_inc");
                  },
                  onLongPress: () {},
                  iconSize: iconSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: Text("vol", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["vol"]!,
                  text: "vol",
                  onPressed: () {},
                  onLongPress: () {
                    changeButtonActive("vol");
                    changeButtonActive("vol_inc");
                    changeButtonActive("vol_dec");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.arrow_back),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["left"]!,
                  onPressed: () {
                    sendOrder("left");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      arrowLeft = true;
                    });
                    Vibration.vibrate(duration: 20);
                    longPress("left", longArrowDelay);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      arrowLeft = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Text("OK"),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["OK"]!,
                  onPressed: () {
                    sendOrder("ok");
                  },
                  onLongPress: () {
                    changeButtonActive("OK");
                  },
                  text: "OK",
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.arrow_forward),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["right"]!,
                  onPressed: () {
                    sendOrder("right");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      arrowRight = true;
                    });
                    Vibration.vibrate(duration: 20);
                    longPress("right", longArrowDelay);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      arrowRight = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon:
                      Text("prog", style: TextStyle(fontSize: iconSize / 2.5)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["prog"]!,
                  text: "prog",
                  onPressed: () {},
                  onLongPress: () {
                    changeButtonActive("prog");
                    changeButtonActive("prgm_inc");
                    changeButtonActive("prgm_dec");
                  },
                  iconSize: iconSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: const Icon(Icons.remove),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["vol_dec"]!,
                  onPressed: () {
                    sendOrder("vol_dec");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      volDown = true;
                    });
                    longPress("vol_dec", longVolumeDelay);
                    Vibration.vibrate(duration: 30);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      volDown = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.menu_open),
                  active: buttonIsActive["green"]!,
                  onPressed: () {
                    sendOrder("green");
                  },
                  onLongPress: () {
                    changeButtonActive("green");
                  },
                  color: Colors.green,
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.arrow_downward),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["down"]!,
                  onPressed: () {
                    sendOrder("down");
                  },
                  onLongPressStart: (details) {
                    setState(() {
                      arrowDown = true;
                    });
                    Vibration.vibrate(duration: 20);
                    longPress("down", longArrowDelay);
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      arrowDown = false;
                    });
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.info),
                  active: buttonIsActive["yellow"]!,
                  onPressed: () {
                    sendOrder("yellow");
                  },
                  onLongPress: () {
                    changeButtonActive("yellow");
                  },
                  color: Colors.yellow,
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.remove),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["prgm_dec"]!,
                  onPressed: () {
                    sendOrder("prgm_dec");
                  },
                  onLongPress: () {},
                  iconSize: iconSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: Text("1", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["1"]!,
                  text: "1",
                  onPressed: () {
                    sendOrder("1");
                  },
                  onLongPress: () {
                    changeButtonActive("1");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("2", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["2"]!,
                  text: "2",
                  onPressed: () {
                    sendOrder("2");
                  },
                  onLongPress: () {
                    changeButtonActive("2");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("3", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "3",
                  active: buttonIsActive["3"]!,
                  onPressed: () {
                    sendOrder("3");
                  },
                  onLongPress: () {
                    changeButtonActive("3");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("4", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "4",
                  active: buttonIsActive["4"]!,
                  onPressed: () {
                    sendOrder("4");
                  },
                  onLongPress: () {
                    changeButtonActive("4");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("5", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "5",
                  active: buttonIsActive["5"]!,
                  onPressed: () {
                    sendOrder("5");
                  },
                  onLongPress: () {
                    changeButtonActive("5");
                  },
                  iconSize: iconSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: Text("6", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "6",
                  active: buttonIsActive["6"]!,
                  onPressed: () {
                    sendOrder("6");
                  },
                  onLongPress: () {
                    changeButtonActive("6");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("7", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "7",
                  active: buttonIsActive["7"]!,
                  onPressed: () {
                    sendOrder("7");
                  },
                  onLongPress: () {
                    changeButtonActive("7");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("8", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "8",
                  active: buttonIsActive["8"]!,
                  onPressed: () {
                    sendOrder("8");
                  },
                  onLongPress: () {
                    changeButtonActive("8");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("9", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "9",
                  active: buttonIsActive["9"]!,
                  onPressed: () {
                    sendOrder("9");
                  },
                  onLongPress: () {
                    changeButtonActive("9");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: Text("0", style: TextStyle(fontSize: iconSize / 2)),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  text: "0",
                  active: buttonIsActive["0"]!,
                  onPressed: () {
                    sendOrder("0");
                  },
                  onLongPress: () {
                    changeButtonActive("0");
                  },
                  iconSize: iconSize,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  icon: const Icon(Icons.fast_rewind),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["bwd"]!,
                  onPressed: () {
                    sendOrder("bwd");
                  },
                  onLongPress: () {
                    sendOrder("prev");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const ImageIcon(AssetImage('lib/assets/playpause.png')),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["play"]!,
                  onPressed: () {
                    sendOrder("play");
                  },
                  onLongPress: () {
                    changeButtonActive("play");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.fast_forward),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["fwd"]!,
                  onPressed: () {
                    sendOrder("fwd");
                  },
                  onLongPress: () {
                    sendOrder("next");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.question_mark),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["random"]!,
                  onPressed: () {
                    sendOrder("random");
                  },
                  onLongPress: () {
                    changeButtonActive("random");
                  },
                  iconSize: iconSize,
                ),
                IconGesture(
                  icon: const Icon(Icons.fiber_manual_record_rounded),
                  active: buttonIsActive["rec"]!,
                  onPressed: () {
                    sendOrder("rec");
                  },
                  onLongPress: () {
                    changeButtonActive("rec");
                  },
                  iconSize: iconSize,
                  color: Colors.red,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconGesture(
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  icon: const Icon(Icons.volume_mute),
                  active: buttonIsActive["mute"]!,
                  onPressed: () {
                    sendOrder("mute");
                  },
                  onLongPress: () {
                    changeButtonActive("mute");
                  },
                  iconSize: iconSize,
                ),
                OutlinedButton(
                    style: !buttonIsActive["home"]!
                        ? const ButtonStyle(
                            splashFactory: NoSplash.splashFactory)
                        : const ButtonStyle(),
                    onPressed: () {
                      if (buttonIsActive["home"]!) sendOrder("home");
                    },
                    onLongPress: () {
                      changeButtonActive("home");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text("free",
                          style: TextStyle(
                              fontSize: 30,
                              color: (buttonIsActive["home"]!)
                                  ? Colors.redAccent
                                  : Colors.grey,
                              fontStyle: FontStyle.italic)),
                    )),
                IconGesture(
                  icon: const Icon(Icons.power_settings_new),
                  color: _themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.grey[300]!,
                  active: buttonIsActive["power"]!,
                  onLongPress: () {
                    changeButtonActive("power");
                  },
                  onPressed: () {
                    sendOrder("power");
                  },
                  iconSize: iconSize,
                )
              ],
            )
          ],
        ));
  }

  Widget pad() {
    return Expanded(
        child: GestureDetector(
            child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    color: _themeMode == ThemeMode.dark
                        ? Colors.grey[800]
                        : Colors.blue),
                child: InfoButton()),
            onTap: () {
              sendOrder("ok");
            },
            onLongPress: () {
              sendOrder("red");
            },
            onDoubleTap: () {
              sendOrder("green");
            },
            onHorizontalDragEnd: (dragEndDetails) {
              if (dragEndDetails.primaryVelocity != null) {
                if (dragEndDetails.primaryVelocity! < 0) {
                  sendOrder("left");
                } else if (dragEndDetails.primaryVelocity! > 0) {
                  sendOrder("right");
                }
              }
            },
            onVerticalDragEnd: (dragEndDetails) {
              if (dragEndDetails.primaryVelocity != null) {
                if (dragEndDetails.primaryVelocity! < 0) {
                  sendOrder("up");
                } else if (dragEndDetails.primaryVelocity! > 0) {
                  sendOrder("down");
                }
              }
            }));
  }

  Widget InfoButton() {
    return Visibility(
      visible: infoButton,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Row(
        children: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                            title: const Text("Pad de control"),
                            content: SizedBox(
                                width: 500,
                                height: 625,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const Text(
                                          "Certains boutons de la télécommande peuvent être remplacés par des gestes sur le pad de control, pour une navigation plus rapide dans les applications de la freebox:"),
                                      ListView.separated(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const Divider(
                                                    height: 3,
                                                    color: Colors.grey),
                                        itemCount: 7,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                [
                                          const ListTile(
                                            leading: Icon(Icons.arrow_forward),
                                            title:
                                                Text("glisser vers la droite"),
                                          ),
                                          const ListTile(
                                            leading: Icon(Icons.arrow_upward),
                                            title: Text("glisser vers le haut"),
                                          ),
                                          const ListTile(
                                            leading: Icon(Icons.arrow_back),
                                            title:
                                                Text("glisser vers la gauche"),
                                          ),
                                          const ListTile(
                                            leading: Icon(Icons.arrow_downward),
                                            title: Text("à vous de deviner"),
                                          ),
                                          const ListTile(
                                            leading: Text("OK"),
                                            title: Text("appui simple"),
                                          ),
                                          const ListTile(
                                            leading: Icon(
                                                Icons
                                                    .subdirectory_arrow_left_rounded,
                                                color: Colors.red),
                                            title: Text("appui long"),
                                          ),
                                          const ListTile(
                                            leading: Icon(
                                              Icons.menu_open,
                                              color: Colors.green,
                                            ),
                                            title: Text("double appui"),
                                          ),
                                        ][index],
                                      ),
                                      const Text(
                                          "Le bouton pour accéder à ce menu peut être désactivé dans les paramètres"),
                                      Row(children: [
                                        Expanded(child: Container()),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text("Ok"))
                                      ])
                                    ],
                                  ),
                                )));
                      });
                },
              ),
              Expanded(child: Container())
            ],
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }

  void longPress(String key, int delay) {
    Future.delayed(Duration(milliseconds: delay), () async {
      bool mustContinue = false;
      switch (key) {
        case "vol_inc":
          mustContinue = volUp;
          break;
        case "vol_dec":
          mustContinue = volDown;
          break;
        case "up":
          mustContinue = arrowUp;
          break;
        case "down":
          mustContinue = arrowDown;
          break;
        case "right":
          mustContinue = arrowRight;
          break;
        case "left":
          mustContinue = arrowLeft;
          break;
        default:
          mustContinue = false;
      }

      if (mustContinue) {
        http.get(Uri.parse(
            'http://hd1.freebox.fr/pub/remote_control?key=$key&code=$code'));
        longPress(key, delay);
      }
    });
  }

  Future<void> sendOrder(String order) async {
    Vibration.vibrate(duration: 10);
    if (code == "") {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("pas de code"),
              content: Text(
                  "Veuillez renseigner le code de la télécommande dans les parametres"),
            );
          });
      return;
    }
    if (order != "random") {
      http.get(Uri.parse(
          'http://hd1.freebox.fr/pub/remote_control?key=$order&code=$code'));
    } else {
      var random = Random();
      int rand = random.nextInt(49) + 1;
      if (rand < 10) {
        http.get(Uri.parse(
            'http://hd1.freebox.fr/pub/remote_control?key=$rand&code=$code')); //7177533
      } else {
        http.get(Uri.parse(
            'http://hd1.freebox.fr/pub/remote_control?key=${rand ~/ 10}&code=$code'));
        http.get(Uri.parse(
            'http://hd1.freebox.fr/pub/remote_control?key=${rand - (rand ~/ 10) * 10}&code=$code'));
      }
    }
  }

  Future<void> _openParam(BuildContext ctx) async {
    await Navigator.pushNamed(context, '/param').then((value) {
      setState(() {
        _getPrefs();
      });
    });
  }
}
