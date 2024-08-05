import 'package:flutter/material.dart';
import 'package:taqos/home.dart';
import 'package:taqos/constants.dart';

// https://github.com/flutter/samples/tree/main/material_3_demo/lib

void main() {
  runApp(const TaqosApp());
}

class TaqosApp extends StatefulWidget {
  const TaqosApp({super.key});

  @override
  State<TaqosApp> createState() => _TaqosAppState();
}

class _TaqosAppState extends State<TaqosApp> {
  ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.baseColor;

  bool get useLightMode => switch (themeMode) {
        ThemeMode.system =>
          View.of(context).platformDispatcher.platformBrightness ==
              Brightness.light,
        ThemeMode.light => true,
        ThemeMode.dark => false
      };

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TAQOS",
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        brightness: Brightness.dark,
      ),
      home: const Home(),
    );
  }
}
