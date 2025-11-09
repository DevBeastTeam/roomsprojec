import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Firebase Storage import

class EditRoomPage extends StatefulWidget {
  final String roomId; // Firestore document ID
  final Map<String, dynamic> roomData; // Existing room data

  const EditRoomPage({required this.roomId, required this.roomData, super.key});

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late TextEditingController _numberController; // ✅ Room number
  late TextEditingController _locationController; // ✅ Location
  late TextEditingController _contactController; // ✅ Contact number

  bool _isLoading = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.roomData['name'] ?? '',
    );
    _priceController = TextEditingController(
      text: widget.roomData['price']?.toString() ?? '',
    );
    _descController = TextEditingController(
      text: widget.roomData['description'] ?? '',
    );
    _imageController = TextEditingController(
      text: widget.roomData['image'] ?? '',
    );
    _numberController = TextEditingController(
      text: widget.roomData['number'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.roomData['location'] ?? '',
    );
    _contactController = TextEditingController(
      text: widget.roomData['contact'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _numberController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // ✅ Pick Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
      // ✅ Upload to Firebase Storage after picking
      await _uploadImageToFirebase();
    }
  }

  // ✅ Upload image to Firebase Storage and get media link
  Future<void> _uploadImageToFirebase() async {
    if (_pickedImageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('room_images')
          .child(
            '${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

      await storageRef.putFile(_pickedImageFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _imageController.text = downloadUrl; // ✅ Save media link in controller
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image uploaded successfully!')),
      );
    } catch (e) {
      debugPrint('❌ Firebase Storage Upload Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRoomInFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('rooms').doc(widget.roomId).update({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descController.text.trim(),
        'image': _imageController.text.trim(),
        'number': _numberController.text.trim(), // ✅ Save number
        'location': _locationController.text.trim(), // ✅ Save location
        'contact': _contactController.text.trim(), // ✅ Save contact
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Room updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Firestore Update Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating room: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = _pickedImageFile != null
        ? Image.file(_pickedImageFile!, height: 160, fit: BoxFit.cover)
        : (widget.roomData['image'] != null &&
              widget.roomData['image'].toString().isNotEmpty)
        ? Image.network(
            widget.roomData['image'],
            height: 160,
            fit: BoxFit.cover,
          )
        : Container(
            height: 160,
            color: Colors.grey[300],
            child: const Center(child: Text('No Image Selected')),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A3D62),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagePreview,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Choose Image from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A3D62),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter room name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Room Price'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter room price' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Room Description',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter description' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Room Number'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _updateRoomInFirestore,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Update Room',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D62),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 30,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
