// lib/models/note_model.dart

class NoteModel {
  final String title;
  final String content;
  final String? imagePath; // nullable — boleh tidak ada gambar
  final DateTime date;

  NoteModel({
    required this.title,
    required this.content,
    required this.date,
    this.imagePath,
  });

  // serialisasi ke Map (untuk simpan ke file / shared prefs / json)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // bikin dari Map / json
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      date: json.containsKey('date') && json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      imagePath: json['imagePath'] != null ? json['imagePath'] as String : null,
    );
  }
}
