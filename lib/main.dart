import 'package:flutter/material.dart';
import 'package:vchat/pages/primary/splash_page.dart';
import 'package:vchat/themes/theme_provide.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvide(),
      child: const VChatApp(),
    ),
  );
}

class VChatApp extends StatelessWidget {
  const VChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      theme: Provider.of<ThemeProvide>(context).themeData,
    );
  }
}
