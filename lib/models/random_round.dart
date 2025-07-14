import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/get_questions.dart';
import 'round.dart';

class RandomRound extends Round {
  GetQuestions returnQuestions = GetQuestions();

  RandomRound({super.questions,});

  @override
  Future<List<Question>> getQuestions() async {
    return await returnQuestions.getGeneralQuestionsFromCacheOrFirebase(desiredCount: 10);
  }

  @override
  String getRoundName() {
    return 'Random Round'; // Replace with localized string if needed
    // Example with localization: AppLocalizations.of(context)!.buildUpRound
  }

  @override
  String getRoundDescription() {
    return 'In this round the points for each question will have a random value';
    // Replace with localization string if needed
  }
}