import 'dart:async';
import 'dart:developer';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/widgets/item_widget/desktop_item.dart';
import 'package:copyable/widgets/responsive.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/pages/home/desktop_home_page.dart';
import 'package:copyable/widgets/item_widget/mobile_item.dart';

import '../globals.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<CopyableItem> itemList = [];
  String query = '/-*';
  late StreamSubscription<html.KeyboardEvent> subs;
  FocusNode textFieldNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textFieldNode.requestFocus();
    if (kIsWeb) {
      subs = html.window.onKeyDown.listen(null);
      log("Attaching listener in Search Page");
      subs.onData((html.KeyboardEvent event) {
        log("Search Page  ${event.key}");

        if (!mounted) {
          subs.cancel();
        }

        if (event.key == 'Escape') {
          selectedIndex.value = 0;
          subs.cancel();
        } else if (event.key == '/') {
          textFieldNode.requestFocus();
        }
      });
    }

    selectedIndex.addListener(selectedIndexListener);
  }

  void selectedIndexListener() {
    if (selectedIndex.value != 3) {
      subs.cancel();
      selectedIndex.removeListener(selectedIndexListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Responsive(
              desktop: _getDesktopSearchBar(),
              tablet: _getDesktopSearchBar(),
              mobile: _getMobileSearchBar(),
            ),
            _getSearchPage(),
          ],
        ),
      ),
    );
  }

  _getDesktopSearchBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: 0.05 * MediaQuery.of(context).size.height,
        left: 0.1 * MediaQuery.of(context).size.width,
        right: 0.1 * MediaQuery.of(context).size.width,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 10.0,
                left: 5.0,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5.0,
                    offset: const Offset(0.0, 0.0),
                    spreadRadius: 4.0,
                  ),
                ],
                color: Theme.of(context).cardColor,
              ),
              child: TextField(
                focusNode: textFieldNode,
                onChanged: (e) {
                  if (e.length >= 3) {
                    query = e;
                    setState(() {});
                  } else {
                    query = '';
                    setState(() {});
                  }
                },
                onSubmitted: (nquery) {},
                decoration: InputDecoration(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 0),
                    child: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.5)),
                  ),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: "Enter query here",
                  contentPadding: const EdgeInsets.only(
                    right: 15.0,
                    left: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getMobileSearchBar() {
    return Container(
      height: 0.2 * getHeight(context),
      decoration: BoxDecoration(
        color: appData.value.globalColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search),
              const Spacer(),
              TextButton(
                child: Text("Cancel",
                    style: TextStyle(color: Colors.white.withOpacity(0.5))),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.white,
                selectionHandleColor: Colors.white54,
                selectionColor: Colors.white30,
              ),
            ),
            child: TextField(
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Type here",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              focusNode: textFieldNode,
              onChanged: (e) {
                if (e.length >= 3) {
                  query = e;
                  setState(() {});
                } else {
                  query = '';
                  setState(() {});
                }
              },
            ),
          ),
          Text(
            "Results: ${itemList.length}",
            style: TextStyle(
              fontSize: appData.value.fontSize - 2,
            ),
          )
        ],
      ),
    );
  }

  Future<List<CopyableItem>> getFuture() async {
    query.trim();

    if (query.length < 3) {
      return [];
    }
    List<CopyableItem> list = [];
    if (isLoggedIn()) {
      list = await cloudDatabase.searchItems(query);
      if (list.isEmpty) {
        list = await cloudDatabase.searchItems(query.toLowerCase());
      }
    } else {
      list = await Provider.of<StaticData>(context, listen: false)
          .searchItems(query);
      if (list.isEmpty) {
        // ignore: use_build_context_synchronously
        list = await Provider.of<StaticData>(context, listen: false)
            .searchItems(query.toLowerCase());
      }
    }
    return list;
  }

  Expanded _getSearchPage() {
    return Expanded(
      child: FutureBuilder<List<CopyableItem>>(
        initialData: const [],
        future: getFuture(),
        builder: (context, AsyncSnapshot<List<CopyableItem>> snapshot) {
          if (snapshot.data != null) {
          log("DATA: ${((snapshot.data!))}");
          }
          if (query.length < 3 || query == '/-*') {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "Enter a query with more than 3 characters to start searching.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("An Error Occured${snapshot.error}"));
            } else if (snapshot.hasData) {
              itemList = snapshot.data!;
              sortPinnedUnpinnedList();

              if (itemList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Center(
                    child: Text(
                      "No Data exists with the following query.\nNote that the search is case sensitive.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return MasonryGridView.count(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.isLargeScreen(context)
                      ? 0.1 * MediaQuery.of(context).size.width
                      : 15,
                  vertical: Responsive.isLargeScreen(context)
                      ? 0.05 * MediaQuery.of(context).size.height
                      : 15,
                ),
                crossAxisCount: Responsive.isLargeScreen(context) ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  if (Responsive.isLargeScreen(context)) {
                    return DesktopItem(
                      isFromSearchPage: true,
                      onDoubleTap: () {
                        editItemIndex = index;

                        selectedIndex.value = 1;
                      },
                      onLongPress: _pinUnPinItem,
                      onDelete: _deleteItem,
                      index: index,
                      item: itemList[index],
                    );
                  }
                  return MobileItem(
                    onDoubleTap: (e) {},
                    onLongPress: (e) {},
                    onDelete: (i, e) {},
                    isEditItem: true,
                    index: index,
                    item: itemList[index],
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
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

  @override
  void dispose() {
    if (kIsWeb) {
      subs.cancel();
      log("Disposed Search Page Listener");
    }
    super.dispose();
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
    setState(() {});
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
    setState(() {});
  }
}
