import '../models/question.dart';
import '../models/get_questions.dart';
import 'round.dart';

class PenaltyRound extends Round {
  GetQuestions returnQuestions = GetQuestions();

  PenaltyRound({super.questions,});

  @override
  Future<List<Question>> getQuestions() async {
    return await returnQuestions.getGeneralQuestionsFromCacheOrFirebase(desiredCount: 10);
  }

  @override
  String getRoundName() {
    return 'Penalty Round'; // Replace with localized string if needed
    // Example with localization: AppLocalizations.of(context)!.buildUpRound
  }

  @override
  String getRoundDescription() {
    return 'In this round you get points deduction for every ';
    // Replace with localization string if needed
  }
}