import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class NoteStorage {
  // Nama file penyimpanan lokal
  final String _fileName = 'notes.json';

  // Dapatkan lokasi folder dokumen aplikasi
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Simpan semua catatan ke file JSON
  Future<void> saveNotes(List<NoteModel> notes) async {
    final file = await _getLocalFile();
    final data = jsonEncode(notes.map((e) => e.toJson()).toList());
    await file.writeAsString(data);
  }

  // Load semua catatan dari file JSON
  Future<List<NoteModel>> loadNotes() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List decoded = jsonDecode(contents);
        return decoded.map((e) => NoteModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
