import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telecommande/icon_gesture.dart';
import 'package:telecommande/pad.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;

class Remote extends StatefulWidget {
  const Remote({super.key, required this.buttonColor});
  final Color buttonColor;

  @override
  State<Remote> createState() => _RemoteState();
}

class _RemoteState extends State<Remote> {
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
    if (prefs.containsKey('buttonIsActive')) {
      setState(() {
        buttonIsActive = json.decode(prefs.getString('buttonIsActive')!);
      });
    }
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
    return OrientationBuilder(builder: (context, orientation) {
      return Flex(
        direction: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconGesture(
                        icon: const Icon(Icons.add),
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        icon: Text("vol",
                            style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        icon: Text("prog",
                            style: TextStyle(fontSize: iconSize / 2.5)),
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        icon:
                            Text("1", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("2", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("3", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("4", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("5", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("6", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("7", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("8", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("9", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        icon:
                            Text("0", style: TextStyle(fontSize: iconSize / 2)),
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        icon: const ImageIcon(
                            AssetImage('lib/assets/playpause.png')),
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
                        color: widget.buttonColor,
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
              )),
          if (showPad)
            Pad(
              buttonColor: widget.buttonColor,
              sendOrder: sendOrder,
              showInfoButton: infoButton,
            ),
        ],
      );
    });
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
}
