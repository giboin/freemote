import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telecommande/remote.dart';
import 'package:telecommande/settings_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Telecommande',
    initialRoute: '/',
    routes: {
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/': (context) => const MyApp(),
      '/param': (context) => const SettingsPage(),
    },
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode =
      PlatformDispatcher.instance.platformBrightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark;

  Future<void> _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('themeMode')) {
      setState(() {
        _themeMode = prefs.getString('themeMode') == "dark"
            ? ThemeMode.dark
            : ThemeMode.light;
      });
    }
  }

  Future<void> _saveThemeMode(String str) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', str);
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
            body: Remote(
              buttonColor: _themeMode == ThemeMode.light
                  ? Colors.black
                  : Colors.grey[300]!,
            )));
  }

  Future<void> _openParam(BuildContext ctx) async {
    await Navigator.pushNamed(context, '/param').then((value) {
      setState(() {
        _getPrefs();
      });
    });
  }
}
