class Question {
  final String questionId;
  final String question;
  final List<String> options;
  final String answer;
  final String difficulty;
  final String category;
  final List<int>? votes;

  Question({
    required this.questionId,
    required this.question,
    required this.options,
    required this.answer,
    required this.difficulty,
    required this.category,
    this.votes,
  });

  factory Question.fromJson(Map<String, dynamic> json, {required String id}) {
    return Question(
      questionId: id, // Pass Firebase key separately
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      difficulty: json['difficulty'],
      category: json['category'],
      votes: json['votes'] != null ? List<int>.from(json['votes']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question,
      'options': options,
      'answer': answer,
      'difficulty': difficulty,
      'category': category,
      if (votes != null) 'votes': votes,
    };
  }
}

