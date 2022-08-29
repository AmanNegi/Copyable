import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

String copyableItemToJSON(CopyableItem item) => json.encode(item.toJson());
CopyableItem copyableItemFromJSON(String data) =>
    CopyableItem.fromJson(json.decode(data));

class CopyableItem {
  final String id;
  final String heading;
  final String text;
  final DateTime time;
  late DateTime? pinnedTime;
  late bool isPinned;
  late String referenceId;

  CopyableItem({
    required this.id,
    required this.text,
    required this.time,
    required this.heading,
    this.pinnedTime,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": text,
      "time": time.millisecondsSinceEpoch,
      'isPinned': isPinned,
      'pinnedTime':
          pinnedTime == null ? null : pinnedTime!.millisecondsSinceEpoch,
      'heading': heading,
    };
  }

  factory CopyableItem.fromJson(Map<String, dynamic> map) {
    return CopyableItem(
      id: map['id'],
      text: map['name'],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
      isPinned: map['isPinned'],
      pinnedTime: map['pinnedTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pinnedTime'])
          : null,
      heading: map['heading'] ?? 'No heading',
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
    return "{-$text, $isPinned-}";
  }
}

List<CopyableItem> convertSnapshotListToItems(QuerySnapshot snapshot) {
  List<CopyableItem> itemList = [];

  List docs = snapshot.docs;

  for (var e in docs) {
    itemList.add(CopyableItem.fromSnapshot(e));
  }

  log("Data From Cloud:  ${docs.length}");
  return itemList;
}
