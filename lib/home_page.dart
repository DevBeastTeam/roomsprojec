import 'package:flutter/material.dart';
import 'package:roomsprojec/whatsapp_fab.dart';
import 'room_list.dart';
import 'room_model.dart';

class HomePage extends StatelessWidget {
  final RoomsModel roomsModel;
  final VoidCallback onUpdate;

  const HomePage({required this.roomsModel, required this.onUpdate, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms — find your next stay'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Login',
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ],
      ),
      body: RoomList(roomsModel: roomsModel, onUpdate: onUpdate),
      floatingActionButton: const WhatsAppFAB(phone: '+923001234567'),
    );
  }
}
