import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/pages/home/mobile_home_page.dart';
import 'package:flutter/material.dart';

class MobileItem extends StatefulWidget {
  final Function(CopyableItem) onDoubleTap;
  final Function(CopyableItem) onLongPress;
  final Function(int, CopyableItem) onDelete;
  final CopyableItem item;
  final int index;
  final bool isEditItem;

  const MobileItem({
    Key? key,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onDelete,
    required this.index,
    required this.item,
    this.isEditItem = false,
  }) : super(key: key);

  @override
  State<MobileItem> createState() => _MobileItemState();
}

class _MobileItemState extends State<MobileItem> {
  bool isPinned = false;
  bool isSelected = false;

  @override
  void initState() {
    isPinned = widget.item.isPinned;
    super.initState();
  }

  void selectedListener() {
    isSelected = false;
    if (mounted) setState(() {});
    isItemSelected.removeListener(selectedListener);
    log("Removing Value Notifier Listeners");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => saveDataToClipBoard(widget.item.text),
      onDoubleTap: () => widget.onDoubleTap(widget.item),
      onLongPress: () {
        if (widget.isEditItem) {
          return;
        }
        widget.onLongPress(widget.item);
        isSelected = true;
        setState(() {});
        isItemSelected.addListener(selectedListener);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: widget.item.isPinned
              ? Theme.of(context).primaryColor
              : const Color(0xFF181C27),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.heading,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: appData.value.fontSize,
                color: headingTextColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _getText(),
              style: TextStyle(
                color: widget.item.isPinned
                    ? pinnedDescriptionTextColor.withOpacity(0.8)
                    : unPinnedDescriptionTextColor,
                fontSize: appData.value.fontSize - 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getText() {
    String widgetText = widget.item.text;
    widgetText.replaceAll(' ', '');
    if (widgetText.length > 150) {
      return '${widgetText.substring(0, 150)} ...more';
    }
    return widgetText;
  }
}
