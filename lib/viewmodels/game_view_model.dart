import 'package:blackcarddenied/models/penalty_round.dart';
import 'package:blackcarddenied/models/popular_opinion_round.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../models/build_up_round.dart';
import '../models/game_data.dart';
import '../models/get_questions.dart';
import '../models/question.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/quickness_round.dart';
import '../models/random_round.dart';
import '../models/round.dart';
import '../models/score.dart';
import '../models/game_data.dart';
import '../views/results_page.dart';
import '../views/group_game_page.dart';
import '../services/navigation_service.dart';
import 'package:logger/logger.dart';
import '../models/rounds_manager.dart';

class GameViewModel extends ChangeNotifier {
  final String gameID;
  final String gameName;
  final String currentPlayerName;
  final bool isPlayerOne;

  GameViewModel({required this.gameID, required this.gameName, required this.currentPlayerName, required this.isPlayerOne});

  final log = Logger();
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final GameData _gameData = GameData();
  final GetQuestions _getQuestions = GetQuestions();

  GameData? get gameData => _gameData;

 // final FirebaseDatabase _database = FirebaseDatabase.instance;
 // final DatabaseReference _scoresRef = FirebaseDatabase.instance.ref('scores');
  final AudioPlayer correctSound = AudioPlayer();
  final AudioPlayer incorrectSound = AudioPlayer();

  List<Question> _questions = [];
  List<Round> _remainingRounds = [];
  Round? round;
  Question? _currentQuestion;
  List<int> _randomPointTotals = [];
  int _buildUpCurrentValue = 25;
  Timer? _countdownTimer;
  Duration _countdownDuration = Duration(seconds: 10);
  List<Question> _currentQuestions = [];

  //GameData gameData = GameData();

  ValueNotifier<bool> showAd = ValueNotifier(false);
  ValueNotifier<int> progressBarValue = ValueNotifier(100);

  int _timeRemaining = 1;
  int get timeRemaining => _timeRemaining;
  final int totalTimeInSeconds = 10;

  int standardValue = 100;
  int penalyDeduction = -50;

  bool _roundInitialized = false;
  bool get roundInitialized => _roundInitialized;
  final roundsManager = RoundsManager();

  Future<void> init() async {
    await correctSound.setSourceAsset('sounds/correct.mp3');
    await incorrectSound.setSourceAsset('sounds/incorrect.mp3');
  }

  Future<void> initializeRounds({String? roundName}) async {
    print("initializeRounds called...");
/*    if (gameData!.remainingRounds.isEmpty) {
      // _currentQuestions = await _getQuestions.getGeneralQuestionsFromCacheOrFirebase(minCount: 10);
      _remainingRounds = [
        RandomRound(),
        QuicknessRound(),
        BuildUpRound(),
        PenaltyRound()
      ];
    } else {
      _remainingRounds = gameData!.remainingRounds;
    }*/

/*    log.i("daRound Name = $roundName");

    if (roundName == RandomRound().getRoundName()){
      round = RandomRound();
    } else  if (roundName == QuicknessRound().getRoundName()){
      round = QuicknessRound();
    } else  if (roundName == BuildUpRound().getRoundName()){
      round = BuildUpRound();
    } else  if (roundName == PenaltyRound().getRoundName()){
      round = PenaltyRound();
    } else  if (roundName == PopularOpinionRound().getRoundName()){
      round = PopularOpinionRound();
    }*/

    round = roundsManager.getCurrentRound();

    //round = (_remainingRounds..shuffle()).removeLast();
    log.i("daRound = ${round?.getRoundName()}");

/*    _currentQuestions = (await round?.getQuestions())!;

    round?.setQuestions(_currentQuestions);*/
    // print("round = $round");


    if (round is RandomRound) {
      _generateRandomPoints();
    }

    _currentQuestion = round?.getCurrentQuestion();
    print("_currentQuestion = ${_currentQuestion?.question}");
    gameData?.currentQuestion = _currentQuestion!.question;
    gameData?.answerA = _currentQuestion!.options[0];
    gameData?.answerB = _currentQuestion!.options[1];
    gameData?.answerC = _currentQuestion!.options[2];
    gameData?.answerD = _currentQuestion!.options[3];
    gameData?.currentCategory = _currentQuestion!.category;


    gameData?.remainingRounds = _remainingRounds;
    gameData?.roundName = round!.getRoundName();
    gameData?.roundDescription = round!.getRoundDescription();

    if (round is RandomRound) {
      print('round is RandomRound');
      gameData?.currentPointTotal = _randomPointTotals[round!.getQuestionIndex()];
    } else if (round is BuildUpRound) {
      print('round is BuildUpRound');
      gameData?.currentPointTotal = _buildUpCurrentValue;
    } else if (round is QuicknessRound){
      print('round is QuicknessRound');
    } else if (round is PenaltyRound){
      print('round is PenaltyRound');
      gameData?.currentPointTotal = standardValue;
    } else if (round is PopularOpinionRound){
      print('round is PopularOpinionRound');
      gameData?.currentPointTotal = standardValue;
    }

    // _startCountdown(_countdownDuration);

   //  startCountdown();
    final playerRef = FirebaseDatabase.instance
        .ref('games/$gameID/players')
        .orderByChild('name')
        .equalTo(currentPlayerName);

    final snapshot = await playerRef.once();

    if (snapshot.snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      final playerKey = data.keys.first;

      await FirebaseDatabase.instance
          .ref('games/$gameID/players/$playerKey')
          .update({'roundCompleted': false});
    }

    _roundInitialized = true;
    notifyListeners();
  }

/*  Future<void> pickARound() async {
    await _getCurrentQuestions();
    gameData?.questionsLoaded = true;
    notifyListeners();
  }

  Future<void> _getCurrentQuestions() async {
    final getQuest = GetQuestions();
    final questionsJson = round is BuildUpRound
        ? await getQuest.getRandomQuestions(10)
        : await getQuest.getRandomQuestions(10);

  //  final cleanedJson = questionsJson.replaceAll("json", "").replaceAll("```", "");
  //  final List<dynamic> decoded = jsonDecode(cleanedJson);
   // _questions = decoded.map((e) => Question.fromJson(e)).toList();
    round?.setQuestions(_questions);
  }*/

  void startRound() {
    _displayNextQuestion();
  }

  void checkAnswer(String userAnswer, int answerIndex) {
    print("$runtimeType userAnswer1 = $userAnswer");
    log.i("questionId = ${round?.getQuestionID()}");

    if (round is PopularOpinionRound){
      submitVote(questionId: round!.getQuestionID(), selectedIndex: answerIndex);
    }

      bool isCorrect = round!.answerQuestion(userAnswer, _getQuestionPointTotal());
      print("$runtimeType isCorrect = $isCorrect");


    print("$runtimeType _timeRemaining = $timeRemaining");

    if (round is BuildUpRound) _updateBuildUpValue(isCorrect);

    if (isCorrect) {
      playCorrectSound();
    } else {
      if (round is PenaltyRound){
        round?.setPenalty(penalyDeduction);
      }
      playIncorrectSound();
    }

    gameData?.currentScore = round!.getScore();
    if (round!.isFinished()) {
      print("Round is finished");
      showAd.value = true;

      gameData?.currentScore = round!.getScore();
      gameData?.totalScore += round!.getScore();
      gameData?.questionsLoaded = false;
      gameData?.roundsCompleted++;

      _countdownTimer?.cancel();
      notifyListeners();

      // dispose();

      updateScoreInFirebase(gameID);

      log.i("navigationService.navigatorKey.currentState ${navigationService.navigatorKey.currentState}");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigationService.navigatorKey.currentState != null) {
          navigationService.navigateTo(ResultsPage(gameID: gameID,
          gameName: gameName, currentPlayerName: currentPlayerName, isPlayerOne: isPlayerOne));
        }
      });
    } else {
      _displayNextQuestion();
    }
  }

  void goToResultsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsPage(gameID: gameID,
          gameName: gameName, currentPlayerName: currentPlayerName, isPlayerOne: isPlayerOne)),
    );
  }

  void _displayNextQuestion() {
    _currentQuestion = round?.getCurrentQuestion();
    print("round getCurrentQuestion= ${round?.getCurrentQuestion()}");
    if (_currentQuestion != null) {
      gameData?.currentQuestion = _currentQuestion!.question;
      gameData?.currentCategory = _currentQuestion!.category;
      if (_currentQuestion!.options.length >= 4) {
        gameData?.answerA = _currentQuestion!.options[0];
        gameData?.answerB = _currentQuestion!.options[1];
        gameData?.answerC = _currentQuestion!.options[2];
        gameData?.answerD = _currentQuestion!.options[3];
      }

    //  _startCountdown(_countdownDuration);
      notifyListeners();
    }
  }

  int _getQuestionPointTotal() {
    if (round is RandomRound) {
      int randomValue = _randomPointTotals[round!.getQuestionIndex()];
      print("$runtimeType randomValue = $randomValue");
      gameData?.currentPointTotal = randomValue;
      return _randomPointTotals[round!.getQuestionIndex()];
    } else if (round is QuicknessRound) {
      return (_timeRemaining).round();
    } else if (round is BuildUpRound) {
      return _buildUpCurrentValue;
    } else if (round is PenaltyRound) {
      return standardValue;
    } else if (round is PopularOpinionRound) {
      return standardValue;
    }
    notifyListeners();
    return standardValue;
  }

  void _updateBuildUpValue(bool isCorrect) {
    if (isCorrect && _buildUpCurrentValue < 125) {
      _buildUpCurrentValue += 25;
    } else if (!isCorrect && _buildUpCurrentValue > 25) {
      _buildUpCurrentValue -= 25;
    }
    gameData?.currentPointTotal = _buildUpCurrentValue;
  }

/*  void _startCountdown(Duration duration) {
    _countdownTimer?.cancel();
  //  _timeRemaining = duration.inMilliseconds;

    _countdownTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      _timeRemaining -= 10;

      if (round is QuicknessRound) {
        gameData?.currentPointTotal = (_timeRemaining / 100).round();
      }

      int progress = ((_timeRemaining / duration.inMilliseconds) * 100).toInt();
      progressBarValue.value = progress;

      gameData?.timeRemaining = _timeRemaining as double;

      if (_timeRemaining <= 0) {
        timer.cancel();
        incorrectSound.resume();
        round?.answerQuestion('', 0);
        if (round?.isFinished() == true) {
          gameData?.currentScore = round!.getScore();
          gameData?.totalScore += round!.getScore();
          gameData?.questionsLoaded = false;
          gameData?.roundsCompleted++;
        } else {
          _displayNextQuestion();
        }

        progressBarValue.value = 0;
        notifyListeners();
      }
    });
  }*/

/*  Future<int> processFinalScore(int totalScore) async {
    await _saveFinalScore(totalScore);
    return await _calculatePercentile();
  }

  Future<void> _saveFinalScore(int score) async {
    final newRef = _scoresRef.push();
    await newRef.set(Score(newRef.key!, score).toJson());
  }

  Future<int> _calculatePercentile() async {
    final snapshot = await _scoresRef.get();

    int scores = 0, scoresBelow = 0;
    int totalScore = gameData.totalScore;

    for (final child in snapshot.children) {
      final value = child.child('score').value;
      if (value is int) {
        scores++;
        if (value <= totalScore) scoresBelow++;
      }
    }

    int percentile = scores > 0 ? ((scoresBelow / scores) * 100).toInt() : 0;
    gameData.percentile = percentile;
    return percentile;
  }*/

  void _generateRandomPoints() {
    _randomPointTotals.clear();
    int sum = 0;

    for (int i = 0; i < 9; i++) {
      int val = (Random().nextInt(21) + 10) * 5;
      _randomPointTotals.add(val);
      sum += val;
    }

    int remaining = 1000 - sum;
    if (remaining >= 50 && remaining <= 150 && remaining % 5 == 0) {
      _randomPointTotals.add(remaining);
    } else {
      while (true) {
        int index = Random().nextInt(9);
        int adjustment = (Random().nextInt(9) - 4) * 5;
        int adjusted = _randomPointTotals[index] + adjustment;
        if (adjusted >= 50 && adjusted <= 150) {
          _randomPointTotals[index] = adjusted;
          break;
        }
      }
      _randomPointTotals.add(1000 - _randomPointTotals.reduce((a, b) => a + b));
    }

    print("_randomPointTotals = $_randomPointTotals");
   // gameData?.currentPointTotal = _randomPointTotals.first;
  }

  Future<void> playCorrectSound() async {
    try {
      await correctSound.play(AssetSource('sounds/correct.wav'));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  Future<void> playIncorrectSound() async {
    try {
      await incorrectSound.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      print('Error playing incorrect sound: $e');
    }
  }

  void startCountdown() {
    _countdownTimer?.cancel(); // Cancel any previous timer
    _timeRemaining = 100; // Start from 100
    notifyListeners(); // Initial update

    const tickRate = Duration(milliseconds: 100); // 0.1 second

    _countdownTimer = Timer.periodic(tickRate, (timer) {
      _timeRemaining--;

      if (round is QuicknessRound) {
        gameData?.currentPointTotal = _timeRemaining; // 1 point per tick
        print("_timeRemaining = $_timeRemaining");
        print("currentPointTotal = ${gameData?.currentPointTotal}");
      }

      if (_timeRemaining <= 0 && !round!.isFinished()) {
        _countdownTimer?.cancel();
        _timeRemaining = 0;
        notifyListeners(); // Final update
        checkAnswer("Incorrect", 0); // handle timeout
        playIncorrectSound();
        startCountdown(); // Restart if needed
      } else if (round!.isFinished()){
        _countdownTimer?.cancel();
        notifyListeners();
      } else {
        notifyListeners(); // Regular update
      }
    });
  }

  Future<void> updateScoreInFirebase(String gameId) async {
    log.i("updateScoreInFirebase called with gameId: $gameId");

    final gameRef = ref.child('games/$gameId');
    final snapshot = await gameRef.get();

    if (!snapshot.exists) {
      log.w("Game with ID $gameId not found.");
      return;
    }

    final gameData = Map<String, dynamic>.from(snapshot.value as Map);
    final players = Map<String, dynamic>.from(gameData['players'] ?? {});

    for (final playerEntry in players.entries) {
      final playerKey = playerEntry.key;
      final playerValue = Map<String, dynamic>.from(playerEntry.value);

      final playerNameInDb = playerValue['name'];
      if (playerNameInDb == currentPlayerName) {
        final currentScore = playerValue['score'] ?? 0;
        final newScore = (currentScore as int) + round!.getScore();

        // Update the player's score
        await gameRef.child('players/$playerKey').update(
            {'score': newScore,
              'roundCompleted': true,
            });

        // Increment currentRound
        if (isPlayerOne){
          final currentRound = gameData['currentRound'] ?? 1;
          await gameRef.update({'currentRound': (currentRound as int) + 1});

          log.i("Advanced to round ${currentRound + 1}.");
        }

        log.i("Updated $currentPlayerName's score to $newScore in game $gameId.");

        return;
      }
    }

    log.w("⚠️ Player '$currentPlayerName' not found in game ID '$gameId'.");
  }

  Future<void> submitVote({
    required String questionId,
    required int selectedIndex,
  }) async {
    log.i("submitVote called...");
    log.i("submitVote questionId = $questionId");
    log.i("submitVote selectedIndex = $selectedIndex");

    final ref = FirebaseDatabase.instance
        .ref()
        .child('questions/popular_opinion_questions/$questionId/votes/$selectedIndex');

    try {
      await ref.runTransaction((currentValue) {
        final currentVotes = currentValue as int? ?? 0;
        return Transaction.success(currentVotes + 1);
      });
    } catch (e) {
      print('Error updating vote: $e');
    }
  }




  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
