import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:map_exam/note.dart';

enum EditScreenMode {
  create,
  edit,
  view,
}

class EditScreenArguments {
  EditScreenMode mode;
  Note? note;

  EditScreenArguments({
    required this.mode,
    this.note,
  });
}

class EditScreen extends StatefulWidget {
  static WidgetBuilder route() => (_) => const EditScreen();

  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EditScreenArguments? args;

  Future<void> onConfirm() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    try {
      if (args?.mode == EditScreenMode.create) {
        await createNewNote(
          FirebaseAuth.instance.currentUser!.uid,
          title,
          description,
        );
      } else if (args?.mode == EditScreenMode.edit) {
        await updateNote(
          title,
          description,
        );
      }

      navigator.pop();
      scaffoldMessengerKey.currentState
          ?.showSnackBar(const SnackBar(content: Text('Note saved')));
    } catch (e) {
      scaffoldMessengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> createNewNote(
      String uid, String title, String content) async {
    if (uid.isEmpty) throw Exception('User ID is empty');
    if (title.isEmpty) throw Exception('Title is empty');
    if (content.isEmpty) throw Exception('Content is empty');

    return FirebaseFirestore.instance.collection('notes').add({
      'uid': uid,
      'title': title,
      'content': content,
    });
  }

  Future<void> updateNote(String title, String content) async {
    final id = args?.note?.id;

    if (id == null) throw Exception('Note ID is null');
    if (title.isEmpty) throw Exception('Title is empty');
    if (content.isEmpty) throw Exception('Content is empty');

    return FirebaseFirestore.instance.collection('notes').doc(id).update({
      'title': title,
      'content': content,
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final EditScreenArguments? args =
        ModalRoute.of(context)?.settings.arguments as EditScreenArguments?;

    setState(() => this.args = args);
    _titleController.text = args?.note?.title ?? '';
    _descriptionController.text = args?.note?.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
    );
  }

  AppBar appBar() {
    final title = args?.mode == EditScreenMode.create
        ? "Add New Note"
        : args?.mode == EditScreenMode.edit
            ? "Edit Note"
            : "View Note";

    final confirmButton = IconButton(
      icon: const Icon(Icons.check_circle, size: 30),
      onPressed: onConfirm,
    );

    final cancelButton = IconButton(
      icon: const Icon(Icons.cancel_sharp, size: 30),
      onPressed: () => navigator.pop(),
    );

    return AppBar(
      leading: Container(),
      centerTitle: true,
      title: Text(title),
      actions: [
        if (args?.mode != EditScreenMode.view) confirmButton,
        cancelButton,
      ],
    );
  }

  Widget body() {
    final isEnabled = args?.mode != EditScreenMode.view;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            initialValue: null,
            enabled: isEnabled,
            decoration: const InputDecoration(
              hintText: 'Type the title here',
            ),
            onChanged: (value) {},
          ),
          const SizedBox(height: 5),
          Expanded(
            child: TextFormField(
                controller: _descriptionController,
                enabled: isEnabled,
                initialValue: null,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Type the description',
                ),
                onChanged: (value) {}),
          ),
        ],
      ),
    );
  }
}
