class Note {
  final String id;
  String? title;
  String? content;

  Note({required this.id, this.title, this.content});

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '', // Use empty string as default if 'id' is null
        title = json['title'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };
}
