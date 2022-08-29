import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/helper/distrib_functions.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/pages/add_upate_page.dart';
import 'package:copyable/pages/search_page.dart';
import 'package:copyable/pages/settings_page.dart';
import 'package:copyable/pages/shortcuts_page.dart';
import 'package:copyable/widgets/item_widget/desktop_item.dart';
import 'package:copyable/widgets/side_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keymap/keymap.dart';
import 'package:provider/provider.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({Key? key}) : super(key: key);

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

ValueNotifier<int> selectedIndex = ValueNotifier(0);
int editItemIndex = -1;

class _DesktopHomePageState extends State<DesktopHomePage> {
  List<CopyableItem> itemList = [];

  @override
  void initState() {
    super.initState();
    if (!isLoggedIn()) {
      Provider.of<StaticData>(context, listen: false).refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardWidget(
      showDismissKey: LogicalKeyboardKey.f10,
      textStyle: const TextStyle(fontSize: 22),
      bindings: _getKeyBindings(),
      child: ValueListenableBuilder<int>(
        child: _getBody(),
        valueListenable: selectedIndex,
        builder: (context, value, child) {
          return Scaffold(
            body: Row(
              children: [
                const SideBarWidget(),
                Expanded(
                  child: _getCurrentPage(value, child!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _getCurrentPage(int value, Widget child) {
    switch (value) {
      case 0:
        return child;
      case 1:
        return AddUpdatePage(
          edit: editItemIndex >= 0,
          oldItem: editItemIndex >= 0 ? itemList[editItemIndex] : null,
        );
      case 2:
        return const ShortcutsPage();
      case 3:
        return const SearchPage();
      case 4:
        return const SettingsPage();
      default:
        return Container();
    }
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
              itemList = convertSnapshotListToItems(snapshot.data);
              sortPinnedUnpinnedList();

              return _getDesktopView();
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
        return _getDesktopView();
      },
    );
  }

  Widget _getDesktopView() {
    return ListView(
      children: [
        MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            horizontal: 0.1 * MediaQuery.of(context).size.width,
            vertical: 0.05 * MediaQuery.of(context).size.height,
          ),
          crossAxisCount: 4,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            // onDoubleTap: _navigateToAddItemPage,
            return DesktopItem(
              onDoubleTap: () {
                editItemIndex = index;

                selectedIndex.value = 1;
              },
              onLongPress: _pinUnPinItem,
              onDelete: _deleteItem,
              index: index,
              item: itemList[index],
            );
          },
        ),
        SizedBox(height: 0.025 * MediaQuery.of(context).size.height),
      ],
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

  List<KeyAction> _getKeyBindings() {
    return [
      KeyAction(LogicalKeyboardKey.f1, 'View Shortcuts', () {
        // Navigator.of(context).pushNamed(shortcutsRoute);
        selectedIndex.value = 2;
      }),
      KeyAction(
        LogicalKeyboardKey.keyV,
        'Save Item from Clipboard',
        () async {
          String? text = await getClipBoardData(context);
          if (text != null) {
            addData(
                context: context,
                text: text,
                heading: getHeadingFromContent(text));
          }
        },
        isControlPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey.slash,
        'Go to Add Item Page',
        () {
          // navigateToAddItemPage(context);
          selectedIndex.value = 1;
        },
      ),
      KeyAction(
        LogicalKeyboardKey.digit1,
        'Copy First Item to notepad',
        () {
          if (itemList.isNotEmpty) saveDataToClipBoard(itemList[0].text);
        },
      ),
      KeyAction(
        LogicalKeyboardKey.digit2,
        'Copy Second Item to notepad',
        () {
          if (itemList.length >= 2) saveDataToClipBoard(itemList[1].text);
        },
      ),
      KeyAction(
        LogicalKeyboardKey.digit3,
        'Copy Third Item to notepad',
        () {
          if (itemList.length >= 3) saveDataToClipBoard(itemList[2].text);
        },
      ),
      KeyAction(
        LogicalKeyboardKey.keyF,
        isControlPressed: true,
        'Go to Search Page',
        () {
          selectedIndex.value = 3;
        },
      ),
    ];
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
}
