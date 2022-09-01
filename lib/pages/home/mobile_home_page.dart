import 'dart:developer';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/widgets/animated_fab.dart';
import 'package:copyable/widgets/exit_app_dialog.dart';
import 'package:copyable/widgets/home_drawer.dart';
import 'package:copyable/widgets/item_widget/mobile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'dart:math' as math;

import 'package:url_launcher/url_launcher.dart';

final GlobalKey fabKey = GlobalKey();
final GlobalKey copyFromClipBoardKey = GlobalKey();
final GlobalKey textFieldFABKey = GlobalKey();

ValueNotifier<bool> isItemSelected = ValueNotifier<bool>(false);

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({Key? key}) : super(key: key);

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  List<CopyableItem> itemList = [];

  int selectedIndex = -1;
  CopyableItem? selectedItem;

  final GlobalKey _itemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!isLoggedIn()) {
      Provider.of<StaticData>(context, listen: false).refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isItemSelected.value) {
          _closeAppBar();
          return false;
        } else {
          return await ExitAppDialog.show(context);
        }
      },
      child: ShowCaseWidget(
        onStart: (e, ei) {},
        builder: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              log('Shown Instructions: ${appData.value.shownInstructions}');
              if (appData.value.shownInstructions) return;
              ShowCaseWidget.of(context).startShowCase([_itemKey, fabKey]);
              localData.updateShownInstructions(true);
            });
            return Scaffold(
              endDrawer: isItemSelected.value ? null : const HomeDrawer(),
              floatingActionButton: ValueListenableBuilder<bool>(
                valueListenable: isItemSelected,
                child: const AnimatedFABWidget(),
                builder: (context, value, child) {
                  if (value) {
                    return FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        saveDataToClipBoard(selectedItem!.text);
                      },
                      child: const Icon(
                        Icons.copy,
                        color: Colors.white,
                      ),
                    );
                  }
                  return child!;
                },
              ),
              appBar: PreferredSize(
                preferredSize: const Size(double.infinity, kToolbarHeight * 2),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isItemSelected,
                  child: _getDefaultAppBar(),
                  builder: (context, value, child) {
                    if (value) {
                      return _getSelectedAppBar();
                    }
                    return child!;
                  },
                ),
              ),
              body: ValueListenableBuilder<bool>(
                valueListenable: isItemSelected,
                child: _getBody(),
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: value,
                          child: child!,
                        ),
                      ),
                      if (value)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => _closeAppBar(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  _closeAppBar() {
    isItemSelected.value = false;
    selectedIndex = -1;
    selectedItem = null;
  }

  _getSelectedAppBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight * 2),
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            leading: null,
            titleSpacing: 0,
            elevation: 0,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    isItemSelected.value = false;
                    selectedIndex = -1;
                    selectedItem = null;
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(MdiIcons.pin),
                  onPressed: () {
                    isItemSelected.value = false;
                    _pinUnPinItem(selectedItem!);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    isItemSelected.value = false;
                    _navigateToAddItemPage(selectedItem!);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    isItemSelected.value = false;
                    _deleteItem(selectedIndex, selectedItem!);
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: cardColor,
            height: kToolbarHeight,
            // color: Colors.green,
            child: Center(
              child: Text(
                "Created on: ${_getDate(selectedItem!.time)}",
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getDate(DateTime date) {
    DateFormat formatter = DateFormat.yMMMd('en_US').add_jm();
    return formatter.format(date);
  }

  AppBar _getDefaultAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: Container(
          width: double.infinity,
          height: kToolbarHeight,
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(searchRoute);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      readOnly: true,
                      enabled: false,
                      onTap: () {},
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(MdiIcons.cloudSearch),
                        hintStyle:
                            TextStyle(color: unPinnedDescriptionTextColor),
                        hintText: "Search your copyables",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () async {
          await launchUrl(
              Uri.parse(
                "https://github.com/AmanNegi/AmanNegi.github.io/blob/main/copyable/README.md",
              ),
              mode: LaunchMode.externalApplication);
        },
        child: Container(
          color: Colors.transparent,
          child: const Text(
            "Copyable",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      elevation: 3,
      automaticallyImplyLeading: false,
      actions: [
        Builder(builder: (context) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(MdiIcons.sortVariant),
            ),
          );
        }),
      ],
    );
  }

  _getBody() {
    if (isLoggedIn()) {
      return StreamBuilder(
        stream: cloudDatabase.getStreamOfData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error Occured"));
            } else if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isItemSelected.value = false;
                selectedIndex = -1;
              });

              itemList = convertSnapshotListToItems(snapshot.data);
              sortPinnedUnpinnedList();

              return _getMobileView();
            }
            return const Center(child: Text("No Data Received"));
          }
          return Center(child: Text(snapshot.connectionState.toString()));
        },
      );
    }
    return Consumer<StaticData>(
      builder: (_, staticData, __) {
        itemList = staticData.getItems();
        sortPinnedUnpinnedList();

        return _getMobileView();
      },
    );
  }

  _getMobileView() {
    return MasonryGridView.count(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 30.0,
        top: 15.0,
      ),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Showcase(
              key: _itemKey,
              title: 'This is your copyable item',
              showcaseBackgroundColor: Theme.of(context).cardColor,
              titleTextStyle: Theme.of(context).textTheme.bodyText1!.copyWith(),
              descTextStyle: Theme.of(context).textTheme.bodyText2!.copyWith(),
              description:
                  'Simply click it once to copy.\nDouble click it to edit.\nHold it for more options.',
              child: MobileItem(
                  onDoubleTap: _navigateToAddItemPage,
                  // onLongPress: _pinUnPinItem,
                  onLongPress: (e) {
                    HapticFeedback.vibrate();
                    isItemSelected.value = true;
                    selectedIndex = index;
                    selectedItem = e;
                  },
                  onDelete: _deleteItem,
                  index: index,
                  item: itemList[index]));
        }

        return MobileItem(
            onDoubleTap: _navigateToAddItemPage,
            // onLongPress: _pinUnPinItem,
            onLongPress: (e) {
              HapticFeedback.vibrate();
              isItemSelected.value = true;
              selectedIndex = index;
              selectedItem = e;
            },
            onDelete: _deleteItem,
            index: index,
            item: itemList[index]);
      },
    );
  }

  List<CopyableItem> sortPinnedUnpinnedList() {
    List<CopyableItem> unpinnedItems = [];
    List<CopyableItem> pinnedItems = [];

    for (int i = 0; i < itemList.length; i++) {
      var item = itemList[i];
      item.isPinned ? pinnedItems.add(item) : unpinnedItems.add(item);
    }

    pinnedItems.sort((a, b) {
      return b.pinnedTime!.compareTo(a.pinnedTime!);
    });

    List<CopyableItem> mergedList = [...pinnedItems, ...unpinnedItems];
    itemList = mergedList;
    return mergedList;
  }

  _deleteItem(int index, CopyableItem e) async {
    if (isLoggedIn()) {
      await cloudDatabase.removeItem(e.id);
    } else {
      Provider.of<StaticData>(
        context,
        listen: false,
      ).removeData(e.id);
    }
  }

  _pinUnPinItem(CopyableItem e) async {
    if (isLoggedIn()) {
      await cloudDatabase.pinItem(e.id, !(e.isPinned));
    } else {
      Provider.of<StaticData>(
        context,
        listen: false,
      ).toggleIsPinned(e.id, !(e.isPinned));
      localData.updateCompleteList(itemList);
    }
  }

  _navigateToAddItemPage(CopyableItem item) {
    Navigator.of(context).pushNamed(createEditRoute, arguments: {
      "edit": true,
      'oldItem': item,
      "text": item.text,
    });
  }
}
