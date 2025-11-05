import 'package:flutter/material.dart';
import 'room_model.dart';
import 'room_details.dart';

class RoomList extends StatelessWidget {
  final RoomsModel roomsModel;
  final VoidCallback onUpdate;
  const RoomList({required this.roomsModel, required this.onUpdate, super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = roomsModel.rooms;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxis = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final r = rooms[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomDetails(id: r.id, roomsModel: roomsModel),
                ),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Image.asset(r.image, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rs ${r.price.toStringAsFixed(0)} / month',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
