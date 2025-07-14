import 'dart:math';
import 'package:blackcarddenied/models/rounds_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/build_up_round.dart';
import '../models/get_questions.dart';
import '../models/penalty_round.dart';
import '../models/popular_opinion_round.dart';
import '../models/question.dart';
import '../models/quickness_round.dart';
import '../models/random_round.dart';
import '../models/round.dart';

class SetupViewModel extends ChangeNotifier {
  final log = Logger();
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();

  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController playerController = TextEditingController();

  String get gameName => gameNameController.text.trim();
  String get playerName => playerController.text.trim();

  bool get isValid => gameName.isNotEmpty && playerName.isNotEmpty;
  final roundsManager = RoundsManager();
  GetQuestions returnQuestions = GetQuestions();

  final random = Random();
  final rounds = ['Random Round', 'Quickness Round', 'Build Up Round', 'Penalty Round', 'Popular Opinion Round'];
  // final rounds = ['Popular Opinion Round', 'Popular Opinion Round', 'Popular Opinion Round', 'Popular Opinion Round', 'Popular Opinion Round'];

  final selectedRounds = <String>[];

  Future<String?> createGameInFirebase({File? imageFile}) async {
    if (!isValid) {
      throw Exception('Game name and player name are required');
    }

    // 1. Pick 3 random rounds
    for (int i = 0; i < 3; i++) {
      final index = random.nextInt(rounds.length);
      final choice = rounds.removeAt(index);
      selectedRounds.add(choice);
    }

    print("selectedRounds = $selectedRounds");

    //  Upload image (if exists)
    String? imageUrl;
    if (imageFile != null) {
      final fileName = const Uuid().v4(); // Generates unique file name
      final imageRef = FirebaseStorage.instance.ref().child('player_images/$fileName.jpg');

      try {
        await imageRef.putFile(imageFile);
        imageUrl = await imageRef.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
      }
    }

    log.i("imageURL = $imageUrl");

    // 3. Create game in Realtime Database
    final gameRef = ref.child('games').push(); // auto-ID for the game
    final gameId = gameRef.key;

    final Map<String, dynamic> gameData = {
      'gameName': gameName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'allowJoin': true,
      'gameStarted': false,
      'playerCounter': 1,
      'currentRound': 1,
      'round1': selectedRounds[0],
      'round2': selectedRounds[1],
      'round3': selectedRounds[2],
      'players': {
        'player1': {
          'name': playerName,
          'score': 0,
          'roundCompleted': false,
          if (imageUrl != null) 'playerImage': imageUrl,
        },
      },
    };

    log.i("gameId = $gameId");

    await gameRef.set(gameData);

    setupRounds(gameId!);
    return gameId;
  }


  Future<String?> joinGameInFirebase({File? imageFile}) async {
    if (!isValid) {
      throw Exception('Game name and player name are required');
    }

    // Upload image (if exists)
    String? imageUrl;
    if (imageFile != null) {
      final fileName = const Uuid().v4();
      final imageRef = FirebaseStorage.instance.ref().child('player_images/$fileName.jpg');

      try {
        await imageRef.putFile(imageFile);
        imageUrl = await imageRef.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
      }
    }

    log.i("imageURL = $imageUrl");

    final gamesRef = ref.child('games');
    final snapshot = await gamesRef.get();

    if (snapshot.exists) {
      final allGames = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in allGames.entries) {
        final gameId = entry.key;
        final gameData = Map<String, dynamic>.from(entry.value);

        final currentGameName = gameData['gameName'];
        final allowJoin = gameData['allowJoin'] == true;

        if (currentGameName == gameName && allowJoin) {
          final players = Map<String, dynamic>.from(gameData['players'] ?? {});
          final playerNumber = (gameData['playerCounter'] ?? players.length) + 1;
          final newPlayerKey = 'player$playerNumber';

          final gameRef = gamesRef.child(gameId);

          await gameRef.update({
            'players/$newPlayerKey': {
              'name': playerName,
              'score': 0,
              'roundCompleted': false,
              if (imageUrl != null) 'playerImage': imageUrl,
            },
            'playerCounter': playerNumber,
          });

          log.i("✅ Joined game with ID: $gameId");

          // 🔽 Now fetch round names (round1, round2, round3)
          final fullGameRef = FirebaseDatabase.instance.ref().child('games/$gameId');
          final fullGameSnapshot = await fullGameRef.get();

          if (fullGameSnapshot.exists) {
            final fullGameData = Map<String, dynamic>.from(fullGameSnapshot.value as Map);

            final round1Name = fullGameData['round1'] as String?;
            final round2Name = fullGameData['round2'] as String?;
            final round3Name = fullGameData['round3'] as String?;

            final roundNamesList = [round1Name, round2Name, round3Name];

            log.i("🎯 round1 = $round1Name");
            log.i("🎯 round2 = $round2Name");
            log.i("🎯 round3 = $round3Name");

            // 🔽 Fetch question IDs for each round
            final roundQuestionsRef = FirebaseDatabase.instance.ref().child('games/$gameId/roundQuestions');

            final roundQuestionsSnapshot = await roundQuestionsRef.get();

            if (roundQuestionsSnapshot.exists) {
              final questionMap = Map<String, dynamic>.from(roundQuestionsSnapshot.value as Map);

              final round1Questions = List<String>.from(questionMap['round1'] ?? []);
              final round2Questions = List<String>.from(questionMap['round2'] ?? []);
              final round3Questions = List<String>.from(questionMap['round3'] ?? []);

              final roundQuestionsList = [round1Questions, round2Questions, round3Questions];

              log.i("📦 round1Questions = $round1Questions");
              log.i("📦 round2Questions = $round2Questions");
              log.i("📦 round3Questions = $round3Questions");

              setupRoundsJoinedGame(roundNamesList, roundQuestionsList);
            }
          }

          return gameId;
        }
      }
    }

    log.w("No joinable game found with name '$gameName'");
    return null;
  }

  Future<void> uploadAllRoundQuestions({
    required String gameId,
    required RoundsManager roundsManager,
  }) async {
    final ref = FirebaseDatabase.instance.ref().child('games/$gameId/roundQuestions');

    final Map<String, dynamic> roundData = {};

    for (var i = 0; i < roundsManager.getRoundCount(); i++) {
      final round = roundsManager.getRound(i);
      final questions = await round?.retrieveQuestions();

      if (questions != null && questions.isNotEmpty) {
        final questionIds = questions.map((q) => q.questionId).toList();
        roundData['round${i + 1}'] = questionIds;
      }
    }

    log.i("uploadAllRoundQuestions = $roundData");

    await ref.set(roundData);
  }


  Future<void> setupRounds(String gameID) async {
    var roundIndex = 1;

    // PHASE 1: Build and store rounds
    for (var roundName in selectedRounds) {
      Round currentRound;

      if (roundName == RandomRound().getRoundName()) {
        currentRound = RandomRound();
      } else if (roundName == QuicknessRound().getRoundName()) {
        currentRound = QuicknessRound();
      } else if (roundName == BuildUpRound().getRoundName()) {
        currentRound = BuildUpRound();
      } else if (roundName == PenaltyRound().getRoundName()) {
        currentRound = PenaltyRound();
      } else if (roundName == PopularOpinionRound().getRoundName()) {
        currentRound = PopularOpinionRound();
      } else {
        continue;
      }

      // Fetch questions so each round is fully initialized
      final newQuestions = await currentRound.getQuestions();
      log.i("Bout to print some questions yo");
      for (var question in newQuestions){
        print(question.questionId);
        print(question.question);
      }
      currentRound.setQuestions(newQuestions);
      log.i("retrieveQuestions = ${currentRound.retrieveQuestions()}");
      // Store the round in manager
      roundsManager.addRound(currentRound);

    }

    log.i("✅ All rounds added to roundsManager count: ${roundsManager.getRoundCount()}");

    // PHASE 2: Upload all round question IDs
    await uploadAllRoundQuestions(gameId: gameID, roundsManager: roundsManager);
  }

  Future<List<Question>> fetchQuestionsByIds(List<String> questionIds, String categoryPath) async {
    final List<Question> questions = [];

    for (String id in questionIds) {
      final ref = FirebaseDatabase.instance.ref('questions/$categoryPath/$id');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final question = Question.fromJson(data, id: id);
        questions.add(question);
      }
    }

    return questions;
  }


  Future<void> setupRoundsJoinedGame(List<String?> roundNames, List<List<String>> roundQuestions) async {
    Round currentRound = Round();
    String categoryPath = "";
    List<List<Question>> finalQuestionsList = [];

    for (var i = 0; i < roundNames.length; i++) {
      if (roundNames[i] == RandomRound().getRoundName()) {
        currentRound = RandomRound();
      } else if (roundNames[i] == QuicknessRound().getRoundName()) {
        currentRound = QuicknessRound();
      } else if (roundNames[i] == BuildUpRound().getRoundName()) {
        currentRound = BuildUpRound();
      } else if (roundNames[i] == PenaltyRound().getRoundName()) {
        currentRound = PenaltyRound();
      } else if (roundNames[i] == PopularOpinionRound().getRoundName()) {
        currentRound = PopularOpinionRound();
      } else {
        continue;
      }

      switch (currentRound) {
        case PopularOpinionRound():
          categoryPath = "popular_opinion_questions";
          break;
        default:
          categoryPath = 'general_questions';
          break;
      }

      final currentRoundQuestions = await fetchQuestionsByIds(
          roundQuestions[i], categoryPath);
      currentRound.setQuestions(currentRoundQuestions);
      roundsManager.addRound(currentRound);

      print("LoadGame Questions");
      for (var question in currentRoundQuestions){
        print(question.question);
      }
    }

  //  log.i("roundsManager count LoadGame = ${roundsManager.getRoundCount()}");
  //  log.i("roundsManager count questions = ${roundsManager.getCurrentRound()?.getQuestions()}");
  }

  void disposeAll() {
    gameNameController.dispose();
    playerController.dispose();
  }
}
