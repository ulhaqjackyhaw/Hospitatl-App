import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:rsapp/main_screen.dart';
import 'firebase_options.dart'; // Firebase options generated for web
// Import Patient Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use the correct platform options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase IoT',
      home: MainScreen(), // Start with the main screen
      debugShowCheckedModeBanner: false, // Matikan debug banner
    );
  }
}
