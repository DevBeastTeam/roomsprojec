import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roomsprojec/user/whatsapp_fab.dart';

class RoomDetailsPage extends StatefulWidget {
  final String roomId; // Firestore document ID

  const RoomDetailsPage({required this.roomId, super.key});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  Map<String, dynamic>? room;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndFetch();
  }

  Future<void> _initializeFirebaseAndFetch() async {
    try {
      await Firebase.initializeApp();
      await _fetchRoomDetails();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase initialization error: $e')),
      );
    }
  }

  Future<void> _fetchRoomDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      if (doc.exists) {
        setState(() {
          room = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Room not found')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching room: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive container width
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.95; // mobile default
    if (screenWidth >= 1200)
      containerWidth = 600; // desktop
    else if (screenWidth >= 800)
      containerWidth = 500; // tablet

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Room Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A3D62),
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: (room?['contact'] ?? '').toString().isNotEmpty
          ? WhatsAppFAB(phone: room!['contact'].toString())
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : room == null
          ? const Center(child: Text('Room not found'))
          : Center(
              child: SizedBox(
                width: containerWidth,
                child: ListView(
                  children: [
                    // ✅ Image Section
                    (room?['image'] ?? '').toString().isNotEmpty
                        ? Image.network(
                            room!['image'].toString(),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 250,
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
                                height: 250,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 80),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 80),
                          ),

                    // ✅ Details Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Room Name
                          Text(
                            room!['name']?.toString() ?? 'Unnamed Room',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A3D62),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Price
                          if ((room?['price'] ?? '').toString().isNotEmpty)
                            Text(
                              '💰 Price: ${room!['price']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            room!['description']?.toString() ??
                                'No description available.',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Room Number
                          if ((room?['number'] ?? '').toString().isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.meeting_room,
                                  color: Color(0xFF0A3D62),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Room No: ${room!['number']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),

                          // Location
                          if ((room?['location'] ?? '').toString().isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Location: ${room!['location']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),

                          // Contact
                          if ((room?['contact'] ?? '').toString().isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Contact: ${room!['contact']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
