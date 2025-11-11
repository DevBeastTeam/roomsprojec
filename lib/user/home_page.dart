import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'room_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      await _fetchRooms();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Firebase Error: $e')));
    }
  }

  Future<void> _fetchRooms() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .orderBy('createdAt', descending: true)
          .get();

      final fetchedRooms = snapshot.docs.map((doc) {
        final data = doc.data();
        // Safe handling for missing id
        data['id'] = doc.id ?? '';
        return data;
      }).toList();

      setState(() {
        rooms = fetchedRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching rooms: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Available Rooms',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A3D62),
        elevation: 3,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
          ? const Center(child: Text("No rooms available"))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: rooms.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return _buildRoomCard(context, room);
                },
              ),
            ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    final imageUrl = (room['image'] ?? '').toString().trim();
    final roomId = (room['id'] ?? '').toString();
    final roomName = (room['name'] ?? 'Unnamed Room').toString();
    final roomPrice = room['price'] != null ? room['price'].toString() : '';
    final roomLocation = (room['location'] ?? '').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (roomId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RoomDetailsPage(roomId: roomId)),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Room ID is missing')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      key: ValueKey(imageUrl),
                      gaplessPlayback: true,
                      loadingBuilder:
                          (context, child, ImageChunkEvent? progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 140,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0A3D62),
                                ),
                              ),
                            );
                          },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 60),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 60),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A3D62),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    roomPrice.isNotEmpty ? "Price: $roomPrice" : '',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    roomLocation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
