import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/edit_screen.dart';
import 'package:map_exam/note.dart';
import 'package:map_exam/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final NavigatorState navigator = navigatorKey.currentState!;
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final ScaffoldMessengerState scaffoldMessenger =
    scaffoldMessengerKey.currentState!;

class HomeScreen extends StatefulWidget {
  static WidgetBuilder route() => (_) => const HomeScreen();
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  int editingToolsIndex = -1;
  bool isLoading = true;
  bool showContent = true;

  void toggleContent() {
    setState(() => showContent = !showContent);
  }

  void toggleEditingTools(int index) {
    int newIndex = index == editingToolsIndex ? -1 : index;
    setState(() => editingToolsIndex = newIndex);
  }

  void viewNote(Note note) {
    navigator.pushNamed(Routes.edit,
        arguments: EditScreenArguments(
          mode: EditScreenMode.view,
          note: note,
        ));
  }

  void editNote(Note note) {
    navigator.pushNamed(Routes.edit,
        arguments: EditScreenArguments(
          mode: EditScreenMode.edit,
          note: note,
        ));
  }

  void addNewNote() {
    navigator.pushNamed(Routes.edit,
        arguments: EditScreenArguments(
          mode: EditScreenMode.create,
        ));
  }

  Future<void> deleteNote(Note note) async {
    await FirebaseFirestore.instance.collection('notes').doc(note.id).delete();

    scaffoldMessengerKey.currentState
        ?.showSnackBar(const SnackBar(content: Text('Note deleted')));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) navigator.pushNamed(Routes.login);

    FirebaseFirestore.instance
        .collection('notes')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        isLoading = false;
        notes = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return Note.fromJson(data);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(notes.length),
      floatingActionButton: floatingActionButton(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.blueGrey),
              itemBuilder: (context, index) => noteTile(notes[index], index),
            ),
    );
  }

  AppBar appBar(int count) {
    return AppBar(
      title: const Text('My Notes'),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.blue.shade200,
          child: Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget noteTile(Note note, int index) {
    final trailingButtons = SizedBox(
      width: 110.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => editNote(note),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.blue,
            ),
            onPressed: () => deleteNote(note),
          ),
        ],
      ),
    );

    return ListTile(
      title: Text(note.title ?? 'Untitled Note'),
      subtitle: showContent ? Text(note.content ?? '') : null,
      trailing: editingToolsIndex == index ? trailingButtons : null,
      onTap: () => viewNote(note),
      onLongPress: () => toggleEditingTools(index),
    );
  }

  Widget floatingActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
            heroTag: 'show-more',
            tooltip: 'Show less. Hide notes content',
            onPressed: toggleContent,
            child: Icon(
              showContent ? Icons.unfold_less : Icons.unfold_more,
            )),
        FloatingActionButton(
          heroTag: 'add-note',
          tooltip: 'Add a new note',
          onPressed: addNewNote,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
