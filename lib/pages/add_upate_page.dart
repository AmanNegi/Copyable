import 'dart:async';
import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/pages/home/desktop_home_page.dart';
import 'package:copyable/widgets/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class AddUpdatePage extends StatefulHookWidget {
  final bool edit;
  final CopyableItem? oldItem;

  const AddUpdatePage({
    Key? key,
    this.edit = false,
    this.oldItem,
  }) : super(key: key);

  @override
  State<AddUpdatePage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddUpdatePage> {
  late TextEditingController _headingEditingController, _textEditingController;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _headingFocusNode = FocusNode();

  bool isViewingMode = false;

  late StreamSubscription<html.KeyboardEvent> subs;
  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.edit ? widget.oldItem!.text : "");

    _headingEditingController =
        TextEditingController(text: widget.edit ? widget.oldItem!.heading : "");

    _headingFocusNode.requestFocus();

    if (kIsWeb) {
      subs = html.window.onKeyDown.listen(null);

      subs.onData((html.KeyboardEvent event) {
        if (kDebugMode) {
          print("AddUpdate Page ${event.key}");
        }
        if (event.key == 'Escape') {
          selectedIndex.value = 0;
          subs.cancel();
        } else if (event.altKey && event.key == 'Enter') {
          validateAndSave();
          subs.cancel();
        }
      });
    }
    selectedIndex.addListener(selectedIndexListener);
  }

  void selectedIndexListener() {
    if (selectedIndex.value != 1) {
      subs.cancel();
      selectedIndex.removeListener(selectedIndexListener);
    }
  }

  @override
  void dispose() {
    log("AddUpdatePage: Disposing Resources");
    _focusNode.dispose();
    _textEditingController.dispose();

    if (kIsWeb) {
      editItemIndex = -1;
      subs.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isLargeScreen(context)
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(MdiIcons.chevronLeft),
                onPressed: () {
                  if (kIsWeb) {
                    subs.cancel();
                  }
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                      !isViewingMode ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    isViewingMode = !isViewingMode;
                    setState(() {});
                  },
                )
              ],
              title: Text(isViewingMode
                  ? "View Item"
                  : widget.edit
                      ? "Edit Item"
                      : "Add Item"),
              elevation: 1,
              shadowColor: Colors.white10,
              backgroundColor: Theme.of(context).backgroundColor,
              // centerTitle: true,
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        heroTag: "UnattachedTag",
        label: Text(
          "Save",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        onPressed: () => validateAndSave(),
      ),
      body: _getBody(),
    );
  }

  SingleChildScrollView _getBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isLargeScreen(context)
            ? 0.1 * MediaQuery.of(context).size.width
            : 15,
        vertical: Responsive.isLargeScreen(context)
            ? 0.025 * MediaQuery.of(context).size.height
            : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Responsive.isDesktop(context)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      ChoiceChip(
                        backgroundColor: cardColor,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 0.025 * getWidth(context),
                          vertical: 0.005 * getHeight(context),
                        ),
                        selectedColor: appData.value.globalColor,
                        label: Text(
                          "View",
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                isViewingMode ? Colors.white : Colors.white54,
                          ),
                        ),
                        selected: isViewingMode,
                        onSelected: (val) {
                          isViewingMode = true;
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        backgroundColor: cardColor,
                        selectedColor: appData.value.globalColor,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 0.025 * getWidth(context),
                          vertical: 0.005 * getHeight(context),
                        ),
                        label: Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                !isViewingMode ? Colors.white : Colors.white54,
                          ),
                        ),
                        selected: !isViewingMode,
                        onSelected: (val) {
                          isViewingMode = false;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                )
              : Container(),
          isViewingMode
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headingEditingController.text,
                      style: TextStyle(
                        color: headingTextColor,
                        fontSize: appData.value.fontSize + 5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GetLinkifiedText(
                        textEditingController: _textEditingController),
                  ],
                )
              : Column(
                  children: [
                    TextField(
                      onSubmitted: (value) {
                        _focusNode.requestFocus();
                      },
                      focusNode: _headingFocusNode,
                      controller: _headingEditingController,
                      maxLines: 1,
                      style: TextStyle(
                        color: headingTextColor,
                        fontSize: appData.value.fontSize + 5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        hintText: "Enter Heading Here",
                        hintStyle: TextStyle(
                          color: headingTextColor.withOpacity(0.5),
                          fontSize: appData.value.fontSize + 5,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    TextField(
                      focusNode: _focusNode,
                      controller: _textEditingController,
                      maxLines: 999,
                      style: const TextStyle(
                        color: unPinnedDescriptionTextColor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        hintText: "Enter Text Here",
                        hintStyle: TextStyle(
                          color: unPinnedDescriptionTextColor.withOpacity(0.8),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void validateAndSave() async {
    if (_textEditingController.text.isEmpty ||
        _textEditingController.text.trim().isEmpty) {
      if (Responsive.isLargeScreen(context)) {
        selectedIndex.value = 0;
        return;
      }

      Navigator.pop(context);
      return;
    }

    if (widget.edit) {
      await updateData(
        item: widget.oldItem!,
        context: context,
        updatedText: _textEditingController.text,
        headingText: _getHeadingText(),
      );
      _textEditingController.clear();
    } else {
      await addData(
        context: context,
        text: _textEditingController.text,
        heading: _getHeadingText(),
      );
      _textEditingController.clear();
    }

    if (kIsWeb) {
      selectedIndex.value = 0;
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  String _getHeadingText() {
    return _headingEditingController.text.trim().isNotEmpty
        ? _headingEditingController.text.trim().length > 30
            ? getHeadingFromContent(_headingEditingController.text)
            : _headingEditingController.text
        : getHeadingFromContent(_textEditingController.text);
  }
}

class GetLinkifiedText extends StatefulWidget {
  const GetLinkifiedText({
    Key? key,
    required TextEditingController textEditingController,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final TextEditingController _textEditingController;

  @override
  State<GetLinkifiedText> createState() => _GetLinkifiedTextState();
}

class _GetLinkifiedTextState extends State<GetLinkifiedText> {
  @override
  void initState() {
    super.initState();
    widget._textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectableLinkify(
      onOpen: (element) {
        launchUrl(
          Uri.parse(element.url),
          mode: LaunchMode.externalApplication,
        );
      },
      text: widget._textEditingController.text,
    );
  }
}
