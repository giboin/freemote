import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _ParamState createState() => _ParamState();
}

class _ParamState extends State<SettingsPage> {
  String code = "";
  bool infoButton = true;
  bool showPad = true;
  double iconSize = 50.0;
  ThemeMode _themeMode = ThemeMode.system;
  TextEditingController textController = TextEditingController();
  Map buttonIsActive = {};

  Future<void> _getCode() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('code')) {
      return;
    }
    setState(() {
      code = prefs.getString('code') ?? "erreur";
    });
  }

  Future<void> _getButtonIsActive() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('buttonIsActive')) {
      return;
    }
    setState(() {
      buttonIsActive =
          json.decode(prefs.getString('buttonIsActive') ?? "{'error':'true'}");
    });
  }

  Future<bool> _getInfoButton() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('infoButton')) {
      return true;
    }
    setState(() {
      infoButton = prefs.getBool('infoButton') ?? true;
    });
    return infoButton;
  }

  Future<bool> _getShowPad() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('showPad')) {
      return true;
    }
    setState(() {
      showPad = prefs.getBool('showPad') ?? true;
    });
    return showPad;
  }

  Future<void> _getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('themeMode')) {
      return;
    }
    setState(() {
      _themeMode = prefs.getString('themeMode') == "dark"
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  Future<double> _getIconSize() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('iconSize')) {
      return 50.0;
    }
    setState(() {
      iconSize = prefs.getDouble('iconSize') ?? 50.0;
    });
    return iconSize;
  }

  Future<void> _saveCode(String str) async {
    final prefs = await SharedPreferences.getInstance();
    code = str;
    prefs.setString('code', code);
  }

  Future<void> _saveButtonIsActive() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('buttonIsActive', json.encode(buttonIsActive));
  }

  Future<void> _saveInfoButton(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    infoButton = bool;
    prefs.setBool('infoButton', infoButton);
  }

  Future<void> _saveShowPad(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    showPad = bool;
    prefs.setBool('showPad', showPad);
  }

  Future<void> _saveIconSize(double dbl) async {
    final prefs = await SharedPreferences.getInstance();
    iconSize = dbl;
    prefs.setDouble('iconSize', iconSize);
  }

  @override
  void initState() {
    super.initState();
    _getCode().then((value) => textController.text = code);
    _getInfoButton();
    _getShowPad();
    _getIconSize();
    _getThemeMode();
    _getButtonIsActive();
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
            appBar: AppBar(
              title: const Text("Paramètres"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: 5,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 3, color: Colors.grey),
                itemBuilder: (BuildContext context, int index) {
                  return [
                    ListTile(
                      title: Row(
                        children: [
                          const Text("code de la télécommande: "),
                          Expanded(
                              child: TextField(
                            controller: textController,
                            onChanged: (str) async {
                              await _saveCode(str);
                            },
                          )),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                          title: Text("trouver le code"),
                                          content: Text(
                                              'Pour trouver le code,\n\n1) sur la freebox, aller dans "réglages"\n\n2) aller dans "système"\n\n3) cliquer sur "Informations Freebox player et Serveur"\n\n4) dans la section "Télécommande", le code est en face de "Code télécommande réseau".'));
                                    });
                              },
                              icon: const Icon(Icons.info))
                        ],
                      ),
                    ),
                    CheckboxListTile(
                        title: const Text("Afficher le pad"),
                        value: showPad,
                        onChanged: (bool? value) {
                          setState(() {
                            _saveShowPad(value ?? true);
                          });
                        }),
                    CheckboxListTile(
                      title: const Text("Bouton d'information sur le pad"),
                      onChanged: (bool? value) {
                        setState(() {
                          infoButton = value!;
                        });
                        _saveInfoButton(infoButton);
                      },
                      value: infoButton,
                    ),
                    ListTile(
                      title: const Text("taille des touches"),
                      subtitle: Slider(
                        onChanged: (value) {
                          setState(() {
                            iconSize = (value * 100).roundToDouble();
                          });
                        },
                        onChangeEnd: (value) {
                          _saveIconSize(iconSize);
                        },
                        value: iconSize / 100,
                      ),
                      trailing: Text(iconSize.toInt().toString()),
                    ),
                    CheckboxListTile(
                        title: Row(children: [
                          const Text("verrouiller les touches"),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                          title: Text("désactiver des touches"),
                                          content: Text(
                                              'En appuyant longuement sur une touche de la télécommande, vous pouvez la désactiver.\nEffectuez un deuxième appui long pour la réactiver, et cochez cette case pour verrouiller cette fonctionnalité'));
                                    });
                              },
                              icon: const Icon(Icons.info))
                        ]),
                        value: buttonIsActive["lock"] ?? false,
                        onChanged: (bool? value) {
                          setState(() {
                            buttonIsActive["lock"] = value ?? false;
                          });
                          _saveButtonIsActive();
                        }),
                  ][index];
                })));
  }
}
