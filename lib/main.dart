import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:theme_project/image_screen.dart';
import 'package:theme_project/providers/background_color_provider.dart';
import 'package:theme_project/home_screen.dart';
import 'package:theme_project/providers/locale_provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(
    name: 'theme-app',
    options:  FirebaseOptions(
    apiKey: "AIzaSyDj1CmlORJAhqRXBuQJ2imEuIWzeMH_CQI",
    appId: "1:457152791382:web:cf71b307ec5c0eda52ccf7",
    messagingSenderId: "457152791382",
    projectId: "theme-app-9862e",
  ),
  ); // Initialize Firebase
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BackgroundColorProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<BackgroundColorProvider, LocaleProvider>(
          builder:(context, backgroundColorProvider, localeProvider, child){
            return ThemeProvider(
              themes: [
                AppTheme(
                  id: "my_light_theme",
                  description: "My Custom Theme Light",
                  data: ThemeData(
                    primaryColor: Colors.black,
                    colorScheme: ColorScheme.fromSwatch().copyWith(
                        primary: Colors.blue,
                        secondary: Colors.greenAccent,
                        background: backgroundColorProvider.mainColor,
                        inversePrimary: Colors.black,
                        tertiary: Colors.white
                    ),
                  ),
                ),
                AppTheme(
                  id: "my_dark_theme",
                  description: "My Custom Theme Dark",
                  data: ThemeData(
                    primaryColor: Colors.white,
                    colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: Colors.black,
                      background: Colors.black54,
                      tertiary: Colors.black,
                      inversePrimary: Colors.white,
                    ),
                  ),
                ),
              ],
              child: ThemeConsumer(
                child: Builder(
                  builder: (themeContext) => MaterialApp(
                    locale: localeProvider.locale,
                    localizationsDelegates: [
                      AppLocalizations.delegate, // Custom delegate
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: [
                      Locale('en', ''),
                      Locale('hi', ''),
                      Locale('ur', ''),
                    ],
                    initialRoute: '/home',
                    debugShowCheckedModeBanner: false,
                    routes: {
                      '/home': (context) => const HomeScreen(),
                      '/image': (context) => const ImageScreen(),
                    },
                    theme: ThemeProvider.themeOf(themeContext).data,
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}