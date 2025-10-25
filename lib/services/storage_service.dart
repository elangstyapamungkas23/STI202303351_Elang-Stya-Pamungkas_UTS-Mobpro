import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class StorageService {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json');
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    try {
      final file = await _getFile();
      final jsonData = jsonEncode(notes.map((e) => e.toJson()).toList());

      // Gunakan compute agar proses berat jalan di background thread
      await compute(_writeToFile, {'path': file.path, 'data': jsonData});
    } catch (e) {
      print('❌ Gagal menyimpan catatan: $e');
    }
  }

  static Future<void> _writeToFile(Map<String, String> args) async {
    final file = File(args['path']!);
    await file.writeAsString(args['data']!, flush: true);
  }

  Future<List<NoteModel>> loadNotes() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List data = jsonDecode(content);
      return data.map((e) => NoteModel.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ Gagal load notes: $e');
      return [];
    }
  }
}
