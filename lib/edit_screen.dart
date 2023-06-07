import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_exam/note.dart';

class EditScreen extends StatefulWidget {
  final Note note;

  const EditScreen({Key? key, required this.note}) : super(key: key);

  static Route route(Note note) {
    return MaterialPageRoute(builder: (_) => EditScreen(note: note));
  }

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title ?? '';
    _descriptionController.text = widget.note.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              size: 30,
            ),
            onPressed: () {
              _saveChanges();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.cancel_sharp,
              size: 30,
            ),
            onPressed: () {
              _cancelEditing();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              enabled: true,
              decoration: const InputDecoration(
                hintText: 'Type the title here',
              ),
              onChanged: (value) {},
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                enabled: true,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Type the description',
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    final String updatedTitle = _titleController.text;
    final String updatedDescription = _descriptionController.text;
    final user = FirebaseAuth.instance.currentUser!;

    final updatedNote = Note(
      id: widget.note.id,
      title: updatedTitle,
      content: updatedDescription,
    );

    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .update(updatedNote.toJson());

      Navigator.of(context).pop();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update the note. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _cancelEditing() {
    Navigator.of(context).pop();
  }
}
