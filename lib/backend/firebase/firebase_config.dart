import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCfQPRsNprlqs7NvBcOGDLcMxz_9VFqpbs",
            authDomain: "prontomenu-6d485.firebaseapp.com",
            projectId: "prontomenu-6d485",
            storageBucket: "prontomenu-6d485.firebasestorage.app",
            messagingSenderId: "753475717424",
            appId: "1:753475717424:web:5148c198a2221e21ffa0f5",
            measurementId: "G-GXW8VHCV2H"));
  } else {
    await Firebase.initializeApp();
  }
}
