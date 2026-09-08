import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; //généré par flutterfire configure
import 'page1.dart';

// Gestionnaire d'état global simple
class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }
}

final appSettings = AppSettings();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); //ici on ajoute le code pour activer le flutter configure et lier a la firebase
  } catch (e) {
    debugPrint("Erreur Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    appSettings.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SanteFocus',
      themeMode: appSettings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
      ),
      locale: appSettings.locale,
      home: const LandingPage(),
    );
  }
}
