import 'package:flutter/material.dart';
import 'package:roomsprojec/room_model.dart';

class EditRoom extends StatefulWidget {
  final Room room;
  final RoomsModel roomsModel;
  const EditRoom({required this.room, required this.roomsModel, super.key});

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  final _form = GlobalKey<FormState>();
  late String title;
  late String desc;
  late double price;

  @override
  void initState() {
    super.initState();
    title = widget.room.title;
    desc = widget.room.description;
    price = widget.room.price;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    final updated = Room(
      id: widget.room.id,
      title: title,
      description: desc,
      price: price,
      image: widget.room.image,
    );
    widget.roomsModel.update(widget.room.id, updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Room')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
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
                initialValue: desc,
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
                initialValue: price.toString(),
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
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
