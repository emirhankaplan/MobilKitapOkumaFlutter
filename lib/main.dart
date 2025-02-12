import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobilproje/screens/profil_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(BookReadingApp());
}

class BookReadingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kitap Okuma Uygulaması',
      theme: ThemeData(primarySwatch: Colors.blue),
      // İlk açılan ekran
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(), // Giriş ekranı
        '/home': (context) => HomeScreen(), // Ana ekran
        '/profile': (context) => ProfileScreen(), // Profil ekranı
        '/favorites': (context) => FavoritesScreen(), // Favoriler ekranı
      },
    );
  }
}
