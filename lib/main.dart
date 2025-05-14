import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foi/auth/services/auth_gate.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/auth/services/geocoding_service.dart';
import 'package:foi/firebase_options.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:foi/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        //restaurant provider
        ChangeNotifierProvider(create: (context) => Restaurant()),
        // DeliveryService
        ChangeNotifierProvider(create: (context) => DeliveryService()),
        // GeocodingService
        Provider(create: (_) => GeocodingService()),
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
