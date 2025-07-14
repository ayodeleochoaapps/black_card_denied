import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/get_questions.dart';
import 'round.dart';

class BuildUpRound extends Round {

  GetQuestions returnQuestions = GetQuestions();
  BuildUpRound({super.questions,});

  @override
  Future<List<Question>> getQuestions() async {
    return await returnQuestions.getGeneralQuestionsFromCacheOrFirebase(desiredCount: 10);
  }


  @override
  String getRoundName() {
    return 'Build Up Round'; // Replace with localized string if needed
    // Example with localization: AppLocalizations.of(context)!.buildUpRound
  }

  @override
  String getRoundDescription() {
    return 'Answer correctly to increase points. Incorrect answers reduce your multiplier.';
    // Replace with localization string if needed
  }

}
