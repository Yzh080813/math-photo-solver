class Record {
  final String id;
  final String imagePath;
  final String answer;
  final List<String> steps;
  final DateTime createdAt;

  Record({
    required this.id,
    required this.imagePath,
    required this.answer,
    required this.steps,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'answer': answer,
    'steps': steps,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Record.fromMap(Map<String, dynamic> map) => Record(
    id: map['id'] as String,
    imagePath: map['imagePath'] as String,
    answer: map['answer'] as String,
    steps: (map['steps'] as List).cast<String>(),
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
