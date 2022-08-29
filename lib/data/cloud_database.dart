import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copyable/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/copyable_item.dart';
import 'local_data.dart';

class CloudDataBase {
  final FirebaseFirestore globalInstance = FirebaseFirestore.instance;

  late CollectionReference userCollection = globalInstance.collection("users");

  Future<UserModel> addUser(User e) async {
    UserModel user = UserModel.fromUser(e);
    await userCollection.doc(user.uid).set(user.toJson());
    return user;
  }

  updateUserDetails(UserModel user) async {
    await userCollection.doc(user.uid).update(
        {'email': user.email, 'uid': user.uid, 'username': user.userName});
  }

  Future<void> addDataToUserList(CopyableItem data) async {
    // userCollection.doc(appData.value.uid).set();
    await userCollection
        .doc(appData.value.uid)
        .collection('items')
        .doc(data.id)
        .set(data.toJson());
  }

  Stream<QuerySnapshot> getUserFromUID(String uid) {
    debugPrint("Finding $uid");
    try {
      return userCollection.where("uid", isEqualTo: uid).snapshots();
    } catch (e) {
      return const Stream.empty();
    }
  }

  Future<void> updateDataItem(CopyableItem item) async {
    log("Updating Data Item with ${item.text}");
    await userCollection
        .doc(appData.value.uid)
        .collection('items')
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> pinItem(String itemId, bool value) async {
    await userCollection
        .doc(appData.value.uid)
        .collection('items')
        .doc(itemId)
        .update({
      'isPinned': value,
      //TODO: Check if working fine
      'pinnedTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeItem(String id) async {
    await userCollection
        .doc(appData.value.uid)
        .collection('items')
        .doc(id)
        .delete();
  }

  Stream<QuerySnapshot> getStreamOfData() {
    return userCollection
        .doc(appData.value.uid)
        .collection('items')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<List<CopyableItem>> searchItems(String query) async {
    var data = await getStreamOfData().first;
    List<CopyableItem> list = convertSnapshotListToItems(data);
    List<CopyableItem> newList = [];

    for (int i = 0; i < list.length; i++) {
      if (list[i].text.contains(query)) {
        newList.add(list[i]);
      }
    }
    return newList;
  }

  Future<bool> uploadLocalDataToCloud(String email) async {
    List<CopyableItem> list = await localData.getData();
    if (list.isNotEmpty) {
      log("Uploading Data From Local Storage");
      await Future.forEach(list, (CopyableItem element) async {
        await addDataToUserList(element);
      });
    }

    await localData.updateCompleteList([]);
    return true;
  }


}

CloudDataBase cloudDatabase = CloudDataBase();
