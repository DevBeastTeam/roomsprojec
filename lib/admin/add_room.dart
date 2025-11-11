import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_link_generator/media_link_generator.dart';
import 'package:roomsprojec/api.dart'; // Upload function

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
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

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

  // ✅ Pick and upload image
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _isLoading = true);

      final bytes = await picked.readAsBytes();
      _pickedImageBytes = bytes;

      // Upload using your API function
      var link = await uploadFileBase64(
        context,
        picked,
        token: "YOUR_TOKEN_HERE",
        folderName: "rooms",
        fromDeviceName: "roomapp",
        isSecret: false,
      );

      setState(() {
        _imageController.text = link;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image uploaded successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error uploading image: $e')));
    }
  }

  // ✅ Add room to Firestore
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
        'number': _numberController.text.trim(),
        'location': _locationController.text.trim(),
        'contact': _contactController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Room added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error adding room: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive width
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9; // mobile default
    if (screenWidth >= 1200)
      containerWidth = 600; // desktop
    else if (screenWidth >= 800)
      containerWidth = 500; // tablet

    final imagePreview = _pickedImageBytes != null
        ? Image.memory(_pickedImageBytes!, height: 180, fit: BoxFit.cover)
        : (_imageController.text.isNotEmpty
              ? Image.network(
                  _imageController.text,
                  height: 180,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: Text('No Image Selected')),
                ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A3D62),
        centerTitle: true,
        elevation: 3,
      ),
      body: Center(
        child: SizedBox(
          width: containerWidth,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imagePreview,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndUploadImage,
                      icon: const Icon(Icons.image),
                      label: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Choose & Upload Image',
                              style: TextStyle(fontSize: 16),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D62),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Room Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Room Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter room name' : null,
                  ),
                  const SizedBox(height: 20),

                  // Room Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Room Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter room price' : null,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Room Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter description' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Room Number
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Room Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image URL
                  TextFormField(
                    controller: _imageController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _addRoomToFirestore,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A3D62),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
