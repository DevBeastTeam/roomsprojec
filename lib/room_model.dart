import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

class Room {
  String id;
  String title;
  String description;
  double price;
  String image;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });
}

class RoomsModel {
  final List<Room> _rooms;

  RoomsModel._(this._rooms);

  factory RoomsModel.sample() {
    return RoomsModel._([
      Room(
        id: 'r1',
        title: 'Modern Studio',
        description: 'Cozy studio near city center and transport.',
        price: 25000,
        image: 'assets/images/room1.jpg',
      ),
      Room(
        id: 'r2',
        title: '2-Bed Apartment',
        description: 'Spacious 2-bed with balcony and lights.',
        price: 45000,
        image: 'assets/images/room2.jpg',
      ),
    ]);
  }

  List<Room> get rooms => List.unmodifiable(_rooms);

  Room? getById(String id) => _rooms.firstWhereOrNull((r) => r.id == id);

  void add(Room room) {
    _rooms.add(room);
  }

  void update(String id, Room newRoom) {
    final i = _rooms.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _rooms[i] = newRoom;
    }
  }

  void delete(String id) {
    _rooms.removeWhere((r) => r.id == id);
  }
}
