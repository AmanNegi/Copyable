import 'package:copyable/data/local_data.dart';
import 'package:copyable/data/static_data.dart';
import 'package:copyable/pages/home_page.dart';
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
      child: MaterialApp(
        onGenerateRoute: getRoutes,
        title: 'Copyable',
        theme: ThemeData(
          fontFamily: "Poppins",
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
        ),
      ),
    );
  }
}
