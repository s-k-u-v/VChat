//import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:vchat/services/media_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// Packages
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

// Services
import './services/navigation_service.dart';
import './services/database_service.dart'; // Import DatabaseService
import './services/cloud_storage_service.dart'; // Import CloudStorageService

// Providers
import './providers/authentication_provider.dart';

// Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* await FirebaseAppCheck.instance.activate(
    //webRecaptchaSiteKey: 'your_web_recaptcha_site_key', // For web
    androidProvider: AndroidProvider.playIntegrity, // Use playIntegrity for Android
    appleProvider: AppleProvider.deviceCheck, // Use deviceCheck for iOS
  ); */

  // Register services with GetIt
  GetIt.instance.registerSingleton<NavigationService>(NavigationService());
  GetIt.instance.registerSingleton<DatabaseService>(DatabaseService()); // Register DatabaseService
  GetIt.instance.registerSingleton<CloudStorageService>(CloudStorageService()); // Register CloudStorageService
  GetIt.instance.registerSingleton<MediaService>(MediaService()); // Register CloudStorageService

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: const VChatApp(), // Start with the main app widget
    ),
  );
}

class VChatApp extends StatelessWidget {
  const VChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VChat',
      theme: ThemeData(
        dialogBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
        scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
        ),
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/splash', // Start with the splash page
      routes: {
        '/splash': (BuildContext context) => SplashPage(
          key: UniqueKey(),
          onInitializationComplete: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        '/login': (BuildContext context) => const LoginPage(),
        '/register': (BuildContext context) => const RegisterPage(),
        '/home': (BuildContext context) => const HomePage(),
      },
    );
  }
}