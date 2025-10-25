import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note_model.dart';

class AddNotePage extends StatefulWidget {
  final Function(NoteModel) onSave; // callback ketika disimpan
  final NoteModel? existingNote; // catatan lama (jika edit)

  const AddNotePage({
    super.key,
    required this.onSave,
    this.existingNote,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    // Jika sedang edit, isi form dengan data lama
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _imagePath = widget.existingNote!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Judul dan isi catatan tidak boleh kosong ❗"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Buat note baru atau update note lama
    final note = NoteModel(
      title: title,
      content: content,
      date: widget.existingNote?.date ?? DateTime.now(),
      imagePath: _imagePath ?? widget.existingNote?.imagePath,
    );

    widget.onSave(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.existingNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Catatan" : "Tambah Catatan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Judul",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Input Isi Catatan
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Isi Catatan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Pilih Gambar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Gambar:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text("Pilih Gambar"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Preview Gambar
            if (_imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
