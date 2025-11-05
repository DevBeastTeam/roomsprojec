import 'package:flutter/material.dart';
import 'room_model.dart';
import 'package:uuid/uuid.dart';

class AddRoom extends StatefulWidget {
  final RoomsModel roomsModel;

  const AddRoom({required this.roomsModel, super.key});
  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final _form = GlobalKey<FormState>();
  String title = '';
  String desc = '';
  double price = 0;
  String image = 'assets/images/room_placeholder.jpg';

  void _save() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    final id = const Uuid().v4();
    final room = Room(
      id: id,
      title: title,
      description: desc,
      price: price,
      image: image,
    );
    widget.roomsModel.add(room);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Room')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (v) => title = v ?? '',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => desc = v ?? '',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (v) => price = double.tryParse(v ?? '0') ?? 0,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a price.';
                  }
                  if (double.tryParse(v) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Create')),
            ],
          ),
        ),
      ),
    );
  }
}
