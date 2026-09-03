// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkProvider() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'password') {
        return true;
      }
    }
  }
  return false;
}
