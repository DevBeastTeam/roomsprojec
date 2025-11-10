import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomsprojec/admin/admin_dashboard.dart';
import 'package:roomsprojec/admin/admin_login.dart';
import 'package:roomsprojec/firebase_options.dart';
import 'package:roomsprojec/user/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Setup global media token
  await setupMediaLinkToken();

  runApp(const RoomsApp());
}

// ✅ Global variable to store MediaLink token
String mediaToken = '';

Future<void> setupMediaLinkToken() async {
  // Option 1: Generate token via email (optional)
  // var token = await MediaLink().generateTokenByEmail(
  //   "devbeast143@gmail.com",
  //   shouldPrint: true,
  // );
  // mediaToken = token ?? '';

  // Option 2: Set token manually (replace with your actual token)
  // mediaToken = "YOUR_API_TOKEN_HERE";
}

class RoomsApp extends StatefulWidget {
  const RoomsApp({super.key});

  @override
  State<RoomsApp> createState() => _RoomsAppState();
}

class _RoomsAppState extends State<RoomsApp> {
  void _updateState() {
    setState(() {});
  }

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
      // ✅ Initial route
      initialRoute: '/',
      // ✅ Routes
      getPages: [
        // Home page
        GetPage(name: '/', page: () => HomePage()),
        // Admin Dashboard page
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(
          name: '/admin',
          page: () => AdminDashboard(onUpdate: () {}),
        ),
      ],
    );
  }
}

// ✅ RoomsModel placeholder (simple class without data)
class RoomsModel {
  RoomsModel();
}
