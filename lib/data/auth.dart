import 'dart:developer';

import 'package:copyable/data/cloud_database.dart';
import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/models/app_data.dart';
import 'package:copyable/models/copyable_item.dart';
import 'package:copyable/models/user_model.dart';
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
      await authManager.auth.currentUser!.updateDisplayName(userName.trim());
      // await authManager.auth.currentUser!.updatePhotoURL(tempImage);

      UserModel user = cloudDatabase.addUser(auth.currentUser!);
      await cloudDatabase.uploadLocalDataToCloud(user.email);

      return true;
    } on FirebaseAuthException catch (error) {
      showToast(error.message.toString());
      return false;
    }
  }

  Future<bool> signUpWithGoogle(BuildContext context) async {
    GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account == null) {
      showToast("An error occured");
      return false;
    }

    GoogleSignInAuthentication authentication = await account.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    UserCredential authResult = await auth.signInWithCredential(credential);

    // UserModel newUser = UserModel(
    //   email: account.email,
    //   profileImage: account.photoUrl ?? tempImage,
    //   userName: account.displayName ?? account.email,
    //   // uid: account.id,
    //   uid: authResult.user!.uid,
    //   isAdmin: false,
    // );
    // await cloudDatabase.addUserFromUserModel(newUser);
    // localData.saveToDevice(
    //   AppModel(loggedIn: true, uid: authResult.user!.uid, user: newUser),
    // );
    showToast("Logged in Successfully");
    return true;
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      return true;
    } on FirebaseAuthException catch (error) {
      showToast(error.message.toString());
      return false;
    }
  }

  forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOutUser() async {
    await auth.signOut();
    localData.updateAppData(AppData(loggedIn: false, uid: ''));

    // await googleSignIn.signOut();
    // localData.saveToDevice(AppModel(loggedIn: false, uid: '', user: null));
  }

  reloadUser() async {
    await auth.currentUser!.reload();
  }
}

AuthManager authManager = AuthManager();
