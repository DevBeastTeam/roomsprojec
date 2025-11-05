import 'package:flutter/material.dart';
import 'room_model.dart';
import 'add_room.dart';
import 'edit_room.dart';

class AdminDashboard extends StatelessWidget {
  final RoomsModel roomsModel;
  final VoidCallback onUpdate;
  const AdminDashboard({
    required this.roomsModel,
    required this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = roomsModel.rooms;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Rooms',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRoom(roomsModel: roomsModel),
                      ),
                    );
                    onUpdate();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Room'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, i) {
                  final r = rooms[i];
                  return Card(
                    child: ListTile(
                      leading: Image.asset(
                        r.image,
                        width: 72,
                        fit: BoxFit.cover,
                      ),
                      title: Text(r.title),
                      subtitle: Text('Rs ${r.price.toStringAsFixed(0)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditRoom(room: r, roomsModel: roomsModel),
                                ),
                              );
                              onUpdate();
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              roomsModel.delete(r.id);
                              onUpdate();
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
