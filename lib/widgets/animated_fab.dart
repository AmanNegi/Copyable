import 'dart:developer';

import 'package:copyable/data/static_data.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/pages/home/mobile_home_page.dart';
import 'package:copyable/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:showcaseview/showcaseview.dart';

class AnimatedFABWidget extends StatefulHookWidget {
  const AnimatedFABWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedFABWidget> createState() => _AnimatedFABWidgetState();
}

class _AnimatedFABWidgetState extends State<AnimatedFABWidget> {
  late AnimationController _animationController;
  late Animation<Color?> _buttonColor;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  bool isOpened = false;

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  @override
  Widget build(BuildContext context) {
    _animationController =
        useAnimationController(duration: const Duration(milliseconds: 500));

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _buttonColor = ColorTween(
      begin: Theme.of(context).primaryColor,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    final Tween<double> turnsTween = Tween<double>(
      begin: 0,
      end: 0.5,
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return SizedBox(
          height: kToolbarHeight * 3 + 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, _translateButton.value * 2.0, 0.0),
                  child: Showcase(
                    key: textFieldFABKey,
                    radius: BorderRadius.circular(120.0),
                    description: 'Add by writing text',
                    showcaseBackgroundColor: Theme.of(context).cardColor,
                    titleTextStyle:
                        Theme.of(context).textTheme.bodyText1!.copyWith(),
                    descTextStyle:
                        Theme.of(context).textTheme.bodyText2!.copyWith(),
                    onTargetClick: () {
                      log("Target is consuming Events");
                      animate();
                    },
                    disposeOnTap: true,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      heroTag: "WriteText",
                      onPressed: () {
                        navigateToAddItemPage(context);
                        animate();
                      },
                      tooltip: "Add by writing text",
                      elevation: 0,
                      child: const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, _translateButton.value, 0.0),
                  child: Showcase(
                    key: copyFromClipBoardKey,
                    radius: BorderRadius.circular(120.0),
                    description: 'Add items from clipboard instantly.',
                    showcaseBackgroundColor: Theme.of(context).cardColor,
                    titleTextStyle:
                        Theme.of(context).textTheme.bodyText1!.copyWith(),
                    descTextStyle:
                        Theme.of(context).textTheme.bodyText2!.copyWith(),
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      heroTag: "ClipBoard",
                      onPressed: () async {
                        String? text = await getClipBoardData(context);
                        if (text != null) {
                          addData(
                            context: context,
                            text: text,
                            heading: getHeadingFromContent(text),
                          );
                        }
                        animate();
                      },
                      elevation: 0,
                      tooltip: "Add directly from clipboard",
                      child: const Icon(
                        Icons.copy,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Showcase(
                key: fabKey,
                radius: BorderRadius.circular(120.0),
                description: 'Click on this button to add items',
                showcaseBackgroundColor: Theme.of(context).cardColor,
                titleTextStyle:
                    Theme.of(context).textTheme.bodyText1!.copyWith(),
                descTextStyle:
                    Theme.of(context).textTheme.bodyText2!.copyWith(),
                onTargetClick: () {
                  animate();
                  ShowCaseWidget.of(context).startShowCase([
                    copyFromClipBoardKey,
                    textFieldFABKey,
                  ]);
                },
                disposeOnTap: true,
                child: FloatingActionButton(
                  heroTag: "OpenClose",
                  backgroundColor: _buttonColor.value,
                  onPressed: () => animate(),
                  elevation: 0,
                  child: RotationTransition(
                    turns: turnsTween.animate(_animationController),
                    child: isOpened
                        ? const Icon(Icons.close, color: Colors.white)
                        : const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

navigateToAddItemPage(BuildContext context) {
  Navigator.of(context).pushNamed(createEditRoute);
}
