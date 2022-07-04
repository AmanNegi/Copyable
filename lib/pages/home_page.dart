import 'dart:developer';

import 'package:copyable/data/auth.dart';
import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/route_generator.dart';
import 'package:copyable/widgets/animated_fab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CopyableItem> itemList = [];

  void reorderData(int oldindex, int newindex) {
    log("Reordering Data");

    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = itemList.removeAt(oldindex);
      itemList.insert(newindex, items);
    });
    localData.updateCompleteList(itemList);
    if (isLoggedIn()) {
      cloudDatabase.swapTwoDataDates(itemList[oldindex], itemList[newindex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(children: [
          DrawerHeader(child: Container()),
          ListTile(
            title: Text(isLoggedIn() ? "Log Out" : "Login"),
            onTap: () async {
              if (isLoggedIn()) {
                await authManager.signOutUser();
              }
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, home, (route) => false);
              }
            },
          ),
        ]),
      ),
      floatingActionButton: const AnimatedFABWidget(),
      appBar: AppBar(
        title: const Text("Copyable"),
        elevation: 0,
        centerTitle: true,
      ),
      body: _getBody(),
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
              itemList = convertSnapshotListToItems(snapshot.data);
              return _getReorderableList();
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
        return _getReorderableList();
      },
    );
  }

  ReorderableListView _getReorderableList() {
    return ReorderableListView(
      onReorder: reorderData,
      clipBehavior: Clip.none,
      proxyDecorator: (child, val, animation) {
        return Material(
          color: Colors.transparent,
          child: Container(
            child: child,
          ),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      children: generateChildList(),
    );
  }

  List<Widget> generateChildList() {
    List<Widget> children = [];
    for (int i = 0; i < itemList.length; i++) {
      children.add(_buildItem(itemList[i], i));
    }
    return children;
  }

  Widget _buildItem(CopyableItem e, int index) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(children: const [
          Spacer(),
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 15),
        ]),
      ),
      key: Key(e.id.toString()),
      onDismissed: (direction) async {
        itemList.removeAt(index);
        setState(() {});
        if (isLoggedIn()) {
          await cloudDatabase.removeItem(e.id);
        } else {
          Provider.of<StaticData>(
            context,
            listen: false,
          ).removeData(e.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0.0, 2.0),
                blurRadius: 5.0,
                spreadRadius: 4.0,
              ),
            ]),
        key: ValueKey(e.toJson().toString()),
        child: GestureDetector(
          onTap: () {
            saveDataToClipBoard(e.text);
          },
          onDoubleTap: () => _navigateToAddItemPage(e),
          child: ListTile(
            title: Text(
              e.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                (index + 1).toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _navigateToAddItemPage(CopyableItem item) {
    Navigator.of(context).pushNamed(createEditRoute, arguments: {
      "edit": true,
      "text": item.text,
    }).then((value) async {
      if (value != null && (value as Map).containsKey("content")) {
        CopyableItem newItem = CopyableItem(
          id: item.id,
          text: value['content'],
          time: item.time,
        );
        if (isLoggedIn()) {
          await cloudDatabase.updateDataItem(newItem);
        } else {
          await Provider.of<StaticData>(context, listen: false)
              .updateData(newItem);
        }
      }
    });
  }
}
