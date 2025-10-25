import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Tambahan untuk format tanggal
import '../models/note_model.dart';
import 'add_note_page.dart';

class HomePage extends StatefulWidget {
  final List<NoteModel> notes;
  final Function(int) onDelete;
  final Function(int, NoteModel) onEdit;

  const HomePage({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catatan Saya",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF5A4636),
          ),
        ),
        centerTitle: true,
      ),
      body: widget.notes.isEmpty
          ? const Center(
              child: Text(
                "Belum ada catatan 😅",
                style: TextStyle(fontSize: 16, color: Color(0xFF5A4636)),
              ),
            )
          : ListView.builder(
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final note = widget.notes[index];
                return GestureDetector(
                  onTap: () {
                    _showNoteDetail(context, note, index);
                  },
                  child: Card(
                    color: const Color(0xFFFFF3C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.imagePath != null &&
                              note.imagePath!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(note.imagePath!),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF5A4636),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // ✅ Tambahan: tampilkan waktu kegiatan

                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm')
                                      .format(note.date),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.brown,
                                  ),
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF5A4636),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddNotePage(
                                      existingNote: note,
                                      onSave: (updatedNote) {
                                        widget.onEdit(index, updatedNote);
                                      },
                                    ),
                                  ),
                                );
                                if (mounted) setState(() {});
                              } else if (value == 'delete') {
                                // ✅ Tampilkan dialog konfirmasi
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Hapus Catatan"),
                                    content: const Text(
                                        "Apakah kamu yakin ingin menghapus catatan ini?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Batal"),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text("Hapus"),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // ✅ FIX: jalankan delete aman di luar dialog context
                                  Future.microtask(() {
                                    if (mounted) {
                                      setState(() {
                                        widget.onDelete(index);
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Hapus')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showNoteDetail(BuildContext context, NoteModel note, int index) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFFF3C2),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.imagePath != null && note.imagePath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(note.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF5A4636),
                  ),
                ),

                // ✅ Tambahan: tampilkan waktu kegiatan di dialog

                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 10),
                  child: Text(
                    "Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(note.date)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.brown,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  note.content,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF5A4636)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Tutup",
                          style: TextStyle(color: Color(0xFF5A4636))),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8B86D),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNotePage(
                                  existingNote: note,
                                  onSave: (updatedNote) {
                                    widget.onEdit(index, updatedNote);
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          }
                        });
                      },
                      child: const Text("Edit"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
