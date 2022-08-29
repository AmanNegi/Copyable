import 'dart:developer';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/app_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
  ]);

  Future<bool> registerUser(
    String email,
    String password,
    String userName,
  ) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      log("Logged In User...");
      try {
        await authManager.auth.currentUser!.updateDisplayName(userName.trim());
      } catch (e) {
        log("An Error Occured $e");
      }
      await localData.updateAppData(AppData(
        loggedIn: true,
        uid: authManager.auth.currentUser!.uid,
        email: email,
        username: userName,
        isFirstTime: false,
        shownInstructions: false,
      ));

      await cloudDatabase.addUser(auth.currentUser!);

      return true;
    } on FirebaseAuthException catch (error) {
      showToast(error.message.toString(), backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      if (userCredential.user == null) {
        showToast("An Error occured while logging you in.", backgroundColor: Colors.red);
        return false;
      }

      // User Pre-exists get username
      var uid = auth.currentUser!.uid;
      var user = await cloudDatabase.getUserFromUID(uid).first;
      var username = (user.docs[0].data() as Map)['username'];
      await localData.updateAppData(
        AppData(
          loggedIn: true,
          uid: uid,
          email: email,
          username: username,
          isFirstTime: false,
          shownInstructions: false,
        ),
      );

      return true;
    } on FirebaseAuthException catch (error) {
      showToast(error.message.toString(), backgroundColor: Colors.red);
      return false;
    }
  }

  forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOutUser() async {
    await auth.signOut();
    localData.updateAppData(AppData(
      loggedIn: false,
      uid: '',
      email: '',
      username: '',
      isFirstTime: false,
      shownInstructions: false,
    ));
  }

  reloadUser() async {
    await auth.currentUser!.reload();
  }
}

AuthManager authManager = AuthManager();
