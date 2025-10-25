import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // ✅ Tambahkan untuk format tanggal
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
  DateTime? _selectedDateTime; // ✅ Tambahan untuk menyimpan waktu kegiatan

  @override
  void initState() {
    super.initState();

    // Jika sedang edit, isi form dengan data lama
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _imagePath = widget.existingNote!.imagePath;
      _selectedDateTime =
          widget.existingNote!.date; // ✅ tampilkan waktu lama jika edit
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

  // ✅ Tambahan: fungsi pilih tanggal dan waktu
  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
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
      // ✅ Simpan waktu kegiatan yang dipilih, atau gunakan waktu lama / sekarang
      date: _selectedDateTime ?? widget.existingNote?.date ?? DateTime.now(),
      imagePath: _imagePath ?? widget.existingNote?.imagePath,
    );

    widget.onSave(note);
    Navigator.pop(context);

    // ✅ Tambahan notifikasi berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Catatan berhasil disimpan ✅"),
        backgroundColor: Colors.green,
      ),
    );
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

            // ✅ Tambahan: Pilih tanggal & waktu kegiatan
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.access_time),
              label: Text(
                _selectedDateTime == null
                    ? "Pilih Waktu Kegiatan"
                    : DateFormat('dd MMM yyyy, HH:mm')
                        .format(_selectedDateTime!),
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
