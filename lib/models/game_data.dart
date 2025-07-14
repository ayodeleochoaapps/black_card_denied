import 'round.dart';

class GameData {
  bool questionsLoaded;
  String roundName;
  int currentPointTotal;
  String clockTime;
  String roundDescription;
  String currentQuestion;
  String currentCategory;
  String answerA;
  String answerB;
  String answerC;
  String answerD;
  int currentScore;
  int totalScore;
  List<Round> remainingRounds;
  bool gameOver;
  int roundsCompleted;
  int percentile;
  double timeRemaining;

  GameData({
    this.questionsLoaded = false,
    this.roundName = "",
    this.currentPointTotal = 0,
    this.clockTime = "5",
    this.roundDescription = "",
    this.currentQuestion = "",
    this.currentCategory = "",
    this.answerA = "",
    this.answerB = "",
    this.answerC = "",
    this.answerD = "",
    this.currentScore = 0,
    this.totalScore = 0,
    this.remainingRounds = const [],
    this.gameOver = false,
    this.roundsCompleted = 0,
    this.percentile = 0,
    this.timeRemaining = 10.0
  });
}
