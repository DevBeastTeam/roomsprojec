import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomsprojec/admin/admin_login.dart';
import 'package:roomsprojec/user/home_page.dart';
import 'package:roomsprojec/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RoomsApp());
}

class RoomsApp extends StatelessWidget {
  const RoomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rooms Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      getPages: [
        // Default HomePage
        GetPage(name: '/', page: () => const HomePage()),
        // Admin Login page
        GetPage(name: '/admin', page: () => const LoginPage()),
      ],
    );
  }
}
