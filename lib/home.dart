import 'package:flutter/material.dart';
import 'package:taqos/constants.dart';
import 'package:taqos/test_screens.dart';
import 'package:taqos/animator.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.colorSelected,
    required this.useLightMode,
    required this.handleBrightnessChange,
    required this.handleColorSelect,
  });

  final bool useLightMode;
  final ColorSeed colorSelected;

  final void Function(bool useLightMode) handleBrightnessChange;
  final void Function(int value) handleColorSelect;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;

  bool controllerInitialized = false;
  bool showMediumSizedLayout = false;
  bool showLargeSizeLayout = false;

  int screenIndex = ScreenSelected.screen1.value;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = controller.status;

    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        showMediumSizedLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizedLayout = true;
        showLargeSizeLayout = false;
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      showMediumSizedLayout = false;
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }

    if (!controllerInitialized) {
      controllerInitialized = true;
      controller.value = width > mediumWidthBreakpoint ? 1 : 0;
    }
  }

  void handleScreenChange(int screenSelected) {
    setState(() {
      screenIndex = screenSelected;
    });
  }

  Widget createScreenFor(
          ScreenSelected screenSelected, bool showNavBarExample) =>
      switch (screenSelected) {
        // TODO: Transition between single/multi screen like in https://github.com/flutter/samples/blob/main/material_3_demo/lib/home.dart#L114
        ScreenSelected.screen1 => const ScreenOne(),
        ScreenSelected.screen2 => const ScreenTwo()
      };

  PreferredSizeWidget createAppBar() {
    return AppBar(
        title: const Text("TAQOS"),
        actions: !showMediumSizedLayout && !showLargeSizeLayout
            ? [
                _BrightnessButton(
                    handleBrightnessChange: widget.handleBrightnessChange),
                _ColorSeedButton(
                  colorSelected: widget.colorSelected,
                  handleColorSelect: widget.handleColorSelect,
                )
              ]
            : [Container()]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: createAppBar(),
          body: createScreenFor(
              ScreenSelected.values[screenIndex], controller.value == 1),
          navigationRail: NavigationRail(
            extended: showLargeSizeLayout,
            destinations: navRailDestinations,
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChange(screenIndex);
              });
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: showLargeSizeLayout
                    ? _ExpandedTrailingActions(
                        handleBrightnessChange: widget.handleBrightnessChange,
                        handleColorSelect: widget.handleColorSelect,
                        useLightMode: widget.useLightMode,
                        colorSelected: widget.colorSelected,
                      )
                    : _TrailingActions(
                        handleBrightnessChange: widget.handleBrightnessChange,
                        colorSelected: widget.colorSelected,
                        handleColorSelect: widget.handleColorSelect,
                      ),
              ),
            ),
          ),
          navigationBar: NavigationBar(
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
              });
            },
            destinations: appBarDestinations,
          ),
        );
      },
    );
  }
}

class _TrailingActions extends StatelessWidget {
  const _TrailingActions({
    required this.handleBrightnessChange,
    required this.colorSelected,
    required this.handleColorSelect,
  });

  final void Function(bool useLightMode) handleBrightnessChange;
  final void Function(int value) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: _BrightnessButton(
            handleBrightnessChange: handleBrightnessChange,
            showTooltipBelow: false,
          ),
        ),
        Flexible(
          child: _ColorSeedButton(
            colorSelected: colorSelected,
            handleColorSelect: handleColorSelect,
          ),
        )
      ],
    );
  }
}

class _ExpandedTrailingActions extends StatelessWidget {
  const _ExpandedTrailingActions({
    required this.handleBrightnessChange,
    required this.handleColorSelect,
    required this.useLightMode,
    required this.colorSelected,
  });

  final void Function(bool) handleBrightnessChange;
  final void Function(int) handleColorSelect;

  final bool useLightMode;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final trailingActionsBody = Container(
      constraints: const BoxConstraints.tightFor(width: navRailWidth),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text("Brightness"),
              Expanded(child: Container()),
              Switch(
                value: useLightMode,
                onChanged: (value) => handleBrightnessChange(value),
              )
            ],
          ),
          const Divider(),
          _ExpandedColorSeedAction(
            handleColorSelect: handleColorSelect,
            colorSelected: colorSelected,
          )
        ],
      ),
    );

    return screenHeight > maxScrollingHeight
        ? trailingActionsBody
        : SingleChildScrollView(
            child: trailingActionsBody,
          );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
    this.showTooltipBelow = true,
  });

  final Function handleBrightnessChange;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;

    return Tooltip(
      preferBelow: showTooltipBelow,
      message: "Toggle brightness",
      child: IconButton(
        icon: isBright
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () => handleBrightnessChange(!isBright),
      ),
    );
  }
}

class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton({
    required this.colorSelected,
    required this.handleColorSelect,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.palette_outlined),
      tooltip: "Select a seed color",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        return List.generate(ColorSeed.values.length, (index) {
          ColorSeed currentColor = ColorSeed.values[index];

          return PopupMenuItem(
            value: index,
            enabled: currentColor != colorSelected,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    currentColor == colorSelected
                        ? Icons.color_lens
                        : Icons.color_lens_outlined,
                    color: currentColor.color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentColor.label),
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleColorSelect,
    );
  }
}

class _ExpandedColorSeedAction extends StatelessWidget {
  const _ExpandedColorSeedAction({
    required this.handleColorSelect,
    required this.colorSelected,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: maxColorSelectHeight),
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          ColorSeed.values.length,
          (index) => IconButton(
            icon: const Icon(Icons.radio_button_unchecked),
            color: ColorSeed.values[index].color,
            isSelected: colorSelected.color == ColorSeed.values[index].color,
            selectedIcon: const Icon(Icons.circle),
            tooltip: ColorSeed.values[index].label,
            onPressed: () => handleColorSelect(index),
          ),
        ),
      ),
    );
  }
}
