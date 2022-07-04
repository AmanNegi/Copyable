import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/copyable_item.dart';
import 'local_data.dart';

// TODO: Manage upper bound

class CloudDataBase {
  final FirebaseFirestore globalInstance = FirebaseFirestore.instance;

  late CollectionReference userCollection = globalInstance.collection("users");

  UserModel addUser(User e) {
    UserModel user = UserModel.fromUser(e);
    userCollection.doc(user.uid).set(user.toJson());
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
        // .orderBy('time', descending: true)
        .snapshots();
  }

// TODO: Create a function that merges the data from Local and Cloud
// TODO: and then posts to the cloud

  Future uploadLocalDataToCloud(String email) async {
    List<CopyableItem> data = await localData.getData();
    if (data.isNotEmpty) {
      log("Uploading Data From Local Storage");
      List<CopyableItem> list = await localData.getData();
      for (var e in list) {
        await addDataToUserList(e);
      }

      showToast("Your local notes were uploaded to $email");
    }
  }

  //* Extra Functions

  Future<void> swapTwoDataDates(CopyableItem item1, CopyableItem item2) async {
    await updateDataItem(
        CopyableItem(id: item1.id, text: item1.text, time: item2.time));
    await updateDataItem(
        CopyableItem(id: item2.id, text: item2.text, time: item1.time));
  }
}

CloudDataBase cloudDatabase = CloudDataBase();
