import 'package:flutter/material.dart';
import 'models/note_model.dart';
import 'pages/home_page.dart';
import 'pages/add_note_page.dart';
import 'pages/gallery_page.dart';
import 'utils/note_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = NoteStorage();
  final notes = await storage.loadNotes();

  runApp(MyApp(storage: storage, notes: notes));
}

class MyApp extends StatefulWidget {
  final NoteStorage storage;
  final List<NoteModel> notes;

  const MyApp({super.key, required this.storage, required this.notes});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<NoteModel> notes;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    notes = widget.notes;
  }

  Future<void> _addNote(NoteModel note) async {
    setState(() {
      notes.add(note);
    });
    await widget.storage.saveNotes(notes);
  }

  Future<void> _deleteNote(int index) async {
    setState(() {
      notes.removeAt(index);
    });
    await widget.storage.saveNotes(notes);
  }

  Future<void> _editNote(int index, NoteModel updatedNote) async {
    setState(() {
      notes[index] = updatedNote;
    });
    await widget.storage.saveNotes(notes);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Gunakan navigatorKey agar context tidak bermasalah
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AddNotePage(
            onSave: (note) async {
              await _addNote(note);

              // Tambahkan snackbar
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                const SnackBar(
                  content: Text("Catatan berhasil disimpan ✅"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFFFF9EC);
    const Color accent = Color(0xFFE8B86D);
    const Color card = Color(0xFFFFF3C2);
    const Color textDark = Color(0xFF5A4636);

    final pages = [
      HomePage(notes: notes, onDelete: _deleteNote, onEdit: _editNote),
      const SizedBox(), // placeholder untuk tombol tambah catatan
      GalleryPage(notes: notes),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // ✅ penting untuk navigasi dari sini
      title: 'Personal Journal',
      theme: ThemeData(
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.light(
          primary: accent,
          surface: card,
          onSurface: textDark,
        ),
      ),
      home: Scaffold(
        body: SafeArea(child: pages[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: card,
          selectedItemColor: accent,
          unselectedItemColor: textDark.withOpacity(0.5),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, // langsung panggil tanpa context
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Catatan"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: "Tambah"),
            BottomNavigationBarItem(
                icon: Icon(Icons.photo_library_outlined), label: "Galeri"),
          ],
        ),
      ),
    );
  }
}
