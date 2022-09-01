import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:flutter/material.dart';

class DesktopItem extends StatefulWidget {
  final Function onDoubleTap;
  final Function onLongPress;
  final Function(int, CopyableItem) onDelete;
  final CopyableItem item;
  final int index;
  final bool isFromSearchPage;

  const DesktopItem({
    Key? key,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onDelete,
    required this.index,
    this.isFromSearchPage = false,
    required this.item,
  }) : super(key: key);

  @override
  State<DesktopItem> createState() => _DesktopItemState();
}

class _DesktopItemState extends State<DesktopItem> {
  bool isHovering = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _getItem();
  }

  _getItem() {
    return MouseRegion(
      onEnter: (e) {
        setState(() => isHovering = true);
      },
      onExit: (e) {
        setState(() => isHovering = false);
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: widget.item.isPinned
                  // ? Theme.of(context).colorScheme.tertiaryContainer
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.heading,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: appData.value.fontSize + 2,
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
                    fontSize: appData.value.fontSize,
                  ),
                ),
              ],
            ),
          ),
          if (isHovering)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  saveDataToClipBoard(widget.item.text);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: widget.item.isPinned
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          tooltip: 'Copy to clipboard',
                          onPressed: () =>
                              saveDataToClipBoard(widget.item.text),
                          icon: const Icon(Icons.copy)),
                      IconButton(
                        tooltip: 'Delete item',
                        onPressed: () =>
                            widget.onDelete(widget.index, widget.item),
                        icon: const Icon(Icons.delete),
                      ),
                      if (!widget.isFromSearchPage)
                        IconButton(
                          tooltip: 'Edit item',
                          onPressed: () => widget.onDoubleTap(),
                          icon: const Icon(Icons.edit),
                        ),
                      IconButton(
                        tooltip: widget.item.isPinned ? 'Unpin' : 'Pin',
                        onPressed: () => widget.onLongPress(widget.item),
                        icon: Icon(
                          widget.item.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getText() {
    String widgetText = widget.item.text;
    widgetText.replaceAll(' ', '');
    if (widgetText.length > 500) return '${widgetText.substring(0, 500)} ...';
    return widgetText;
  }
}
