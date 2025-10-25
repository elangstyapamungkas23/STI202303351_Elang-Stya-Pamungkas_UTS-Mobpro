import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note_model.dart';

class GalleryPage extends StatelessWidget {
  final List<NoteModel> notes;

  const GalleryPage({Key? key, required this.notes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // warna tema (butter yellow)
    final Color bg = const Color(0xFFFFF9EC);
    final Color accent = const Color(0xFFE8B86D);
    final Color textDark = const Color(0xFF5A4636);

    // ambil paths secara aman (jika NoteModel belum punya imagePath, hasilnya "")
    final List<String> imagePaths = notes
        .map((n) {
          try {
            // akses secara defensif: jika field ada dan tidak kosong, kembalikan String
            final dynamic maybe = n;
            final v = (maybe.imagePath);
            if (v is String && v.isNotEmpty) return v;
          } catch (_) {}
          return "";
        })
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Galeri',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: imagePaths.isEmpty
          ? Center(
              child: Text(
                'Belum ada foto di galeri 📸',
                style: TextStyle(color: textDark, fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: imagePaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final path = imagePaths[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullImageView(imagePath: path),
                        ),
                      );
                    },
                    child: Hero(
                      tag: path,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.28),
                              blurRadius: 6,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: accent.withOpacity(0.12),
                              child: Center(
                                child: Icon(Icons.broken_image,
                                    size: 40, color: textDark.withOpacity(0.8)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class FullImageView extends StatelessWidget {
  final String imagePath;
  const FullImageView({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFFFFF9EC);
    final Color textDark = const Color(0xFF5A4636);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          'Lihat Foto',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
            errorBuilder: (ctx, err, stack) => Icon(
              Icons.image_not_supported,
              size: 100,
              color: textDark.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
