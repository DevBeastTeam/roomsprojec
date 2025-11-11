import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_link_generator/media_link_generator.dart';
import 'package:roomsprojec/api.dart';

class EditRoomPage extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;

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
  late TextEditingController _numberController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;

  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

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

  // ✅ Pick and upload image using media_link_generator
  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _isLoading = true);

      final bytes = await picked.readAsBytes();
      _pickedImageBytes = bytes;

      var link = await uploadFileBase64(
        context,
        picked,
        token: "2f09ddc7ca4c9ba65272b60ae5b09b50", // apna token dalen
        folderName: "rooms",
        fromDeviceName: "roomapp",
        isSecret: false,
      );

      setState(() {
        _imageController.text = link;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Update Firestore Data
  Future<void> _updateRoomInFirestore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({
            'name': _nameController.text.trim(),
            'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
            'description': _descController.text.trim(),
            'image': _imageController.text.trim(),
            'number': _numberController.text.trim(),
            'location': _locationController.text.trim(),
            'contact': _contactController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Room updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error updating room: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = _pickedImageBytes != null
        ? Image.memory(_pickedImageBytes!, height: 160, fit: BoxFit.cover)
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndUploadImage,
                  icon: const Icon(Icons.image),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Choose & Upload Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D62),
                    foregroundColor: Colors.white,
                  ),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
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
