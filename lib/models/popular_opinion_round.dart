import '../models/question.dart';
import '../models/get_questions.dart';
import 'round.dart';

class PopularOpinionRound extends Round {

  GetQuestions returnQuestions = GetQuestions();
  PopularOpinionRound({super.questions,});

  @override
  Future<List<Question>> getQuestions() async {
    return await returnQuestions.getPopularOpinionQuestionsFromCacheOrFirebase(desiredCount: 10);
  }


  @override
  String getRoundName() {
    return 'Popular Opinion Round'; // Replace with localized string if needed
    // Example with localization: AppLocalizations.of(context)!.buildUpRound
  }

  @override
  String getRoundDescription() {
    return 'In this round you get credit for a correct answer if you select the most popular answer.';
    // Replace with localization string if needed
  }

}