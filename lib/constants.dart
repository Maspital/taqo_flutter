import 'package:flutter/material.dart';

const double transitionLength = 500;

const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;

const double navRailWidth = 250;
const double maxColorSelectHeight = 200;

const double maxScrollingHeight = 500;

enum ColorSeed {
  baseColor('FKIE', Color.fromARGB(255, 23, 156, 125)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ScreenSelected {
  screen1(0),
  screen2(1);

  const ScreenSelected(this.value);
  final int value;
}

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: 'This is test screen 1',
    icon: Icon(Icons.widgets_outlined),
    label: 'Screen 1',
    selectedIcon: Icon(Icons.widgets),
  ),
  NavigationDestination(
    tooltip: 'This is test screen 2',
    icon: Icon(Icons.format_paint_outlined),
    label: 'Screen 2',
    selectedIcon: Icon(Icons.format_paint),
  ),
];

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Tooltip(
          message: destination.label,
          child: destination.icon,
        ),
        selectedIcon: Tooltip(
          message: destination.label,
          child: destination.selectedIcon,
        ),
        label: Text(destination.label),
      ),
    )
    .toList();
