import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/pages/add_upate_page.dart';
import 'package:copyable/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

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
      begin: Colors.green,
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
      end: -14.0,
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform(
              transform: Matrix4.translationValues(
                  0.0, _translateButton.value * 2.0, 0.0),
              child: FloatingActionButton(
                heroTag: "WriteText",
                onPressed: () {
                  _navigateToAddItemPage();
                  animate();
                },
                tooltip: "Add by writing text",
                elevation: 0,
                child: const Icon(Icons.edit_note),
              ),
            ),
            Transform(
              transform:
                  Matrix4.translationValues(0.0, _translateButton.value, 0.0),
              child: FloatingActionButton(
                heroTag: "ClipBoard",
                onPressed: () {
                  Provider.of<StaticData>(context, listen: false)
                      .addDataFromClipboard();
                  animate();
                },
                elevation: 0,
                tooltip: "Add directly from clipboard",
                child: const Icon(Icons.copy),
              ),
            ),
            FloatingActionButton(
              heroTag: "OpenClose",
              backgroundColor: _buttonColor.value,
              onPressed: () => animate(),
              elevation: 0,
              child: RotationTransition(
                turns: turnsTween.animate(_animationController),
                child:
                    isOpened ? const Icon(Icons.close) : const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  _navigateToAddItemPage() {
    Navigator.of(context).pushNamed(createEditRoute).then((value) async {
      if (value != null && (value as Map).containsKey("content")) {
        Provider.of<StaticData>(context, listen: false).addData(
          CopyableItem(
            id: localData.getAvailableID(),
            text: value['content'].trim(),
            time: DateTime.now(),
          ),
        );
      }
    });
  }
}
