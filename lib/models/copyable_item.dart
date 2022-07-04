import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

String copyableItemToJSON(CopyableItem item) => json.encode(item.toJson());
CopyableItem copyableItemFromJSON(String data) =>
    CopyableItem.fromJson(json.decode(data));

class CopyableItem {
  final String id;
  final String text;
  final DateTime time;
  final bool isPinned;
  late String referenceId;

  CopyableItem({
    required this.id,
    required this.text,
    required this.time,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": text,
      "time": time.millisecondsSinceEpoch,
      'isPinned': isPinned,
    };
  }

  factory CopyableItem.fromJson(Map<String, dynamic> map) {
    return CopyableItem(
      id: map['id'],
      text: map['name'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
      isPinned: map['isPinned'],
    );
  }
  factory CopyableItem.fromSnapshot(DocumentSnapshot data) {
    CopyableItem value =
        CopyableItem.fromJson(data.data() as Map<String, dynamic>);
    value.referenceId = data.reference.id;
    return value;
  }

  @override
  String toString() {
    return "{-$text-}";
  }
}

List<CopyableItem> convertSnapshotListToItems(QuerySnapshot snapshot) {
  List<CopyableItem> itemList = [];

  List docs = snapshot.docs;

  for (var e in docs) {
    itemList.add(CopyableItem.fromSnapshot(e));
  }

  log("Data From Cloud: $itemList ${docs.length}");
  return itemList;
}
