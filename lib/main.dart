import 'dart:developer';

import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDY-Xt_r72Wz4mt0Q7aFKKUTFbJFcJLE4o",
            appId: "1:264900394130:android:fceefe0c709e2f4d8dfa4b",
            messagingSenderId: "264900394130",
            projectId: "copyable-fab0b"));
  } else {
    await Firebase.initializeApp();
  }

  await localData.initAppData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StaticData(),
      child: ValueListenableBuilder(
        valueListenable: appData,
        builder: (context, value, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: getRoutes,
            title: 'Copyable',
            theme: ThemeData(
              backgroundColor: bgColor,
              scaffoldBackgroundColor: bgColor,
              cardColor: cardColor,
              fontFamily: "Poppins",
              progressIndicatorTheme:
                  ProgressIndicatorThemeData(color: appData.value.globalColor),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: appData.value.globalColor,
                selectionHandleColor: appData.value.globalColor,
                selectionColor: appData.value.globalColor.withOpacity(0.2),
              ),
              brightness: Brightness.dark,
              inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: appData.value.globalColor),
              )),
              primaryColor: appData.value.globalColor,
              textTheme: TextTheme(
                bodyText1: TextStyle(
                  color: Colors.white.withOpacity(0.87),
                  fontSize: appData.value.fontSize,
                ),
                bodyText2: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: appData.value.fontSize,
                ),
                headline6: TextStyle(
                  fontSize: appData.value.fontSize + 5,
                ),
                headline5: TextStyle(
                  fontSize: appData.value.fontSize + 2,
                ),
              ),
            ),
            //TODO: Test This
            initialRoute: kIsWeb
                ? (isLoggedIn() ? homeRoute : loginRoute)
                : !appData.value.isFirstTime
                    ? homeRoute
                    : loginRoute,
          );
        },
      ),
    );
  }
}
