import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/get_questions.dart';
import 'round.dart';

class QuicknessRound extends Round {
  GetQuestions returnQuestions = GetQuestions();

  QuicknessRound({super.questions,});

  @override
  Future<List<Question>> getQuestions() async {
    return await returnQuestions.getGeneralQuestionsFromCacheOrFirebase(desiredCount: 10);
  }

  @override
  String getRoundName() {
    return 'Quickness Round'; // Replace with localized string if needed
    // Example with localization: AppLocalizations.of(context)!.buildUpRound
  }

  @override
  String getRoundDescription() {
    return 'In this round the quicker you select the correct answer the more points you receive';
    // Replace with localization string if needed
  }
}