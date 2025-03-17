import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foi/services/auth/auth_gate.dart';
// import 'package:foi/services/auth/login_or_register.dart';
import 'package:foi/firebase_options.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:foi/themes/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async{


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:  DefaultFirebaseOptions.currentPlatform);


  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        //restaurant provider
        ChangeNotifierProvider(create: (context) => Restaurant()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

