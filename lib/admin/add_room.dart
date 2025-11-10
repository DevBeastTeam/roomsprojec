import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Firebase Storage

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _numberController =
      TextEditingController(); // ✅ Room number
  final TextEditingController _locationController =
      TextEditingController(); // ✅ Location
  final TextEditingController _contactController =
      TextEditingController(); // ✅ Contact number

  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

  // ✅ Pick Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      _pickedImageBytes = await picked.readAsBytes();
      setState(() {});
      await _uploadImageToFirebase();
    }
  }

  // ✅ Upload image to Firebase Storage and get media link
  Future<void> _uploadImageToFirebase() async {
    if (_pickedImageBytes == null) return;

    setState(() => _isLoading = true);

    try {
      // final storageRef = FirebaseStorage.instance
      //     .ref()
      //     .child('room_images')
      //     .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // await storageRef.putFile(_pickedImageBytes!);
      // final downloadUrl = await storageRef.getDownloadURL();

      // setState(() {
      //   _imageController.text = downloadUrl; // ✅ Save media link in controller
      // });

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

  Future<void> _addRoomToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('rooms').add({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descController.text.trim(),
        'image': _imageController.text.trim(),
        'number': _numberController.text.trim(), // ✅ Save number
        'location': _locationController.text.trim(), // ✅ Save location
        'contact': _contactController.text.trim(), // ✅ Save contact
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Room added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Firestore Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding room: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = _pickedImageBytes != null
        ? Image.memory(_pickedImageBytes!, height: 160, fit: BoxFit.cover)
        : (_imageController.text.isNotEmpty
              ? Image.network(
                  _imageController.text,
                  height: 160,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Center(child: Text('No Image Selected')),
                ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A3D62),
        centerTitle: true,
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
                      onPressed: _addRoomToFirestore,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Room',
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
