import 'question.dart'; // Make sure to define the Question model

class Round {
  List<Question> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;

  Round({List<Question>? questions}) : _questions = questions ?? [];

  Question? getCurrentQuestion() {
    print("_currentQuestionIndex = $_currentQuestionIndex");
    print("_questions.length = ${_questions.length}");
    print("_questionsID = ${_questions[_currentQuestionIndex].questionId}");

    return _currentQuestionIndex < _questions.length
        ? _questions[_currentQuestionIndex]
        : null;
  }

  String getQuestionID(){
    return _questions[_currentQuestionIndex].questionId;
  }


  void setQuestions(List<Question> fetchedQuestions) {
    _questions = fetchedQuestions;
  }

  Future<List<Question>> getQuestions() async {
    return _questions;
  }

  Future<List<Question>> retrieveQuestions() async {
    return _questions;
  }

  String getRoundName() {
    return "ROUND Name";
  }

  String getRoundDescription() {
    return "ROUND Description";
  }

  bool answerQuestion(String userAnswer, int questionValue) {
    final currentQuestion = getCurrentQuestion();
    print("currentQuestion = $currentQuestion");
    if (currentQuestion != null) {
      print("userAnswer = $userAnswer");
      print("currentQuestion.answer = ${currentQuestion.answer}");
      final isCorrect = userAnswer == currentQuestion.answer;
      if (isCorrect) {
        _score += questionValue;
        print("$runtimeType _score ROUND = $_score");
      }
      print("_currentQuestionIndex++;");
      _currentQuestionIndex++;
      return isCorrect;
    }
    return false;
  }

  int getScore() => _score;

  setPenalty(int scoreAdjustment){
    if (_score > 0){
      _score = _score + scoreAdjustment;
    }
  }

  int getQuestionIndex() => _currentQuestionIndex;

  bool isFinished() => _currentQuestionIndex >= _questions.length;
}
