import 'package:flutter/material.dart';
import 'package:roomsprojec/admin_dashboard.dart';
import 'package:roomsprojec/home_page.dart';
import 'package:roomsprojec/room_model.dart';

void main() {
  runApp(const RoomsApp());
}

class RoomsApp extends StatefulWidget {
  const RoomsApp({super.key});

  @override
  State<RoomsApp> createState() => _RoomsAppState();
}

class _RoomsAppState extends State<RoomsApp> {
  final RoomsModel _roomsModel = RoomsModel.sample();

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rooms Website',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/admin':
            page = AdminDashboard(
              roomsModel: _roomsModel,
              onUpdate: _updateState,
            );
            break;
          case '/':
          default:
            page = HomePage(roomsModel: _roomsModel, onUpdate: _updateState);
            break;
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }
}
