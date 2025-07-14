class Score {
  final String id;
  final int score;

  Score(this.id, this.score);

  // Named constructor for JSON deserialization
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      json['id'] ?? '',
      json['score'] ?? 0,
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
    };
  }
}