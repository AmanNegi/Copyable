import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/models/app_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool saveToDevice = false;

showToast(String message, {Color? backgroundColor}) {
  if (!kIsWeb) Fluttertoast.cancel();

  String bgColor;
  if (backgroundColor == null) {
    bgColor = appData.value.globalColor.value.toRadixString(16);
  } else {
    bgColor = backgroundColor.value.toRadixString(16);
  }

  bgColor = "#${bgColor.substring(2)}";
  log("BG COLOR: $bgColor");
  Fluttertoast.showToast(
    msg: message,
    timeInSecForIosWeb: 2,
    textColor: Colors.white,
    gravity: ToastGravity.BOTTOM,
    // backgroundColor: appData.value.globalColor,
    webPosition: 'center',
    webBgColor: bgColor,
  );
}

double getWidth(context) => MediaQuery.of(context).size.width;
double getHeight(context) => MediaQuery.of(context).size.height;

const Color fadedTextColor = Color(0xFF6B6D83);
const Color bgColor = Color(0xFF0E121B);
const Color cardColor = Color(0xFF181C27);
const Color headingTextColor = Color(0xFFFDFFFF);

const Color unPinnedDescriptionTextColor = Color(0xFF81899C);
Color pinnedDescriptionTextColor = const Color(0xFFE8E8E8);

List<Color> colorList = [
  const Color(0xFF3369FF),
  defaultColor,
  const Color(0xFFAE3B76),
  const Color(0xFFCB6657),
];

const Color defaultColor = Colors.teal;
// Color(0xFF135B7B);

void changeFontSize(double newValue) async {
  AppData data = appData.value;
  data.fontSize = newValue;

  await localData.updateAppData(data);
}

const String welcomeText =
    """Welcome to Copyable ❤️. Leave your items on the board and copy them in a click whenever needed. 

   - Find the web🌐 application at https://amannegi.github.io/copyable/
   
   - Find the mobile📱 application at https://play.google.com/store/apps/details?id=com.aster.copyable
    """;

const String loremText = """
Aute ullamco fugiat magna adipisicing aliqua eiusmod. Labore aliquip nisi tempor sit magna sint qui non. In sint dolore non sit ullamco. Exercitation pariatur dolor nisi quis.

Sit laboris minim consequat officia velit elit. Commodo fugiat Lorem nulla ea. Est pariatur consequat excepteur pariatur laboris aliqua reprehenderit esse elit consequat reprehenderit. Laboris eiusmod sint ex exercitation consequat ut veniam occaecat do nostrud. Deserunt fugiat minim elit in reprehenderit excepteur irure reprehenderit sint eiusmod. Cupidatat irure quis duis et nisi consequat.

Id est Lorem dolor duis labore sit dolor nostrud et aliquip. Aliquip sunt sunt ea id qui pariatur. Eu nostrud consequat consequat aute pariatur laborum. Consectetur cupidatat ea elit anim non ipsum. Consequat consequat nisi exercitation ex minim. Ea duis ullamco sunt eu nulla consectetur aliquip et. Reprehenderit laborum labore pariatur eiusmod.

Aliqua Lorem laboris nisi ipsum deserunt incididunt irure commodo Lorem quis nisi proident culpa. Veniam aliqua cupidatat est laboris ad dolor. Voluptate do nulla ea deserunt fugiat occaecat consequat minim voluptate mollit consequat pariatur culpa. Occaecat incididunt adipisicing excepteur anim consectetur nulla aute consequat aute. Veniam ea nisi commodo dolore elit adipisicing. Minim aliquip aute in sit duis sint eu dolor eiusmod. Nostrud ut sunt duis pariatur amet reprehenderit voluptate dolore amet proident qui pariatur id tempor.

Exercitation Lorem Lorem nulla aute. Exercitation dolore minim quis ullamco. Incididunt nulla mollit in quis minim. Amet aliquip velit commodo non commodo.
""";
