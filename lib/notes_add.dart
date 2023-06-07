import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/home_screen.dart';

class AddNotesScreen extends StatefulWidget {
  final VoidCallback
      onNoteAdded; // Callback function to invoke after adding a note

  const AddNotesScreen({Key? key, required this.onNoteAdded}) : super(key: key);

  static Route route({required VoidCallback onNoteAdded}) => MaterialPageRoute(
      builder: (_) => AddNotesScreen(onNoteAdded: onNoteAdded));

  @override
  _AddNotesScreenState createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addNote() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final noteData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'email': user.email,
      };

      try {
        await _firestore.collection('notes').add(noteData);
        // Note added successfully
        widget
            .onNoteAdded(); // Invoke the callback to reload notes in HomeScreen
        Navigator.of(context).pop(); // Go back to the previous screen
      } catch (e) {
        // Error occurred while adding the note
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to add the note. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _cancelEditing() {
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: const Text('Add New Note'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              size: 30,
            ),
            onPressed: () {
              _addNote();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
