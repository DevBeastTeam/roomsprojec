import 'package:flutter/material.dart';
import 'room_model.dart';

class RoomDetails extends StatelessWidget {
  final String id;
  final RoomsModel roomsModel;
  const RoomDetails({required this.id, required this.roomsModel, super.key});

  @override
  Widget build(BuildContext context) {
    final room = roomsModel.getById(id);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Room not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(room.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(room.image),
              const SizedBox(height: 12),
              Text(room.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                'Price: Rs ${room.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
