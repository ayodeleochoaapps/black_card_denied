import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'question.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class GetQuestions {

  final log = Logger();

  Future<List<Question>> getGeneralQuestionsFromCacheOrFirebase({int desiredCount = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_general_questions');

    List<Question> cachedQuestions = [];

    // Check SharedPreferences cache
    if (cachedJson != null) {
      final decoded = jsonDecode(cachedJson) as List;
      cachedQuestions = decoded.map((q) => Question.fromJson(q, id: q['questionId'] ?? "")).toList();

      if (cachedQuestions.length >= desiredCount) {
        cachedQuestions.shuffle();
        final selected = cachedQuestions.take(desiredCount).toList();
        final remaining = cachedQuestions.skip(desiredCount).toList();
        await prefs.setString(
          'cached_general_questions',
          jsonEncode(remaining.map((q) => q.toJson()).toList()),
        );
        return selected;
      }
    }

    // Fetch from Firebase
    final ref = FirebaseDatabase.instance.ref().child('questions/general_questions');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value;

      List<Question> fetchedQuestions;

      if (data is List) {
        // Unexpected structure (no keys = no questionId)
        fetchedQuestions = data
            .asMap()
            .entries
            .where((entry) => entry.value != null)
            .map((entry) {
          final map = Map<String, dynamic>.from(entry.value);
          return Question.fromJson(map, id: entry.key.toString());
        })
            .toList();
      } else if (data is Map) {
        // Normal case: keys are question IDs
        fetchedQuestions = (data).entries
            .map((entry) {
          final id = entry.key.toString();
          final map = Map<String, dynamic>.from(entry.value);
          return Question.fromJson(map, id: id);
        })
            .toList();
      } else {
        return [];
      }

      fetchedQuestions.shuffle();

      final selectedQuestions = fetchedQuestions.take(desiredCount).toList();
      final remaining = fetchedQuestions.skip(desiredCount).toList();

      // Cache the remaining questions
      final encoded = jsonEncode(remaining.map((q) => q.toJson()).toList());
      await prefs.setString('cached_general_questions', encoded);

      return selectedQuestions;
    }

    return [];
  }


  Future<List<Question>> getPopularOpinionQuestionsFromCacheOrFirebase({int desiredCount = 10}) async {
    log.i("getP getPopularOpinionQuestionsFromCacheOrFirebase called");
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_popular_opinion_questions');

    List<Question> cachedQuestions = [];

    // Step 1: Load cache if it exists
    if (cachedJson != null) {
      final decoded = jsonDecode(cachedJson) as List;
      cachedQuestions = decoded.map((q) => Question.fromJson(q, id: q['questionId'] ?? "0")).toList();
    }

    // Step 2: If cache has enough questions, return random subset and update cache
    if (cachedQuestions.length >= desiredCount) {
      cachedQuestions.shuffle();
      final selectedQuestions = cachedQuestions.take(desiredCount).toList();
      final remainingQuestions = cachedQuestions.skip(desiredCount).toList();

      final encoded = jsonEncode(remainingQuestions.map((q) => q.toJson()).toList());
      await prefs.setString('cached_popular_opinion_questions', encoded);

      return selectedQuestions;
    }

    // Step 3: Fetch from Firebase
    final ref = FirebaseDatabase.instance.ref().child('questions/popular_opinion_questions');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value;

      List<Question> fetchedQuestions;

      if (data is List) {
        // Unkeyed list, fallback: use index as ID
        fetchedQuestions = data
            .asMap()
            .entries
            .where((entry) => entry.value != null)
            .map((entry) {
          final map = Map<String, dynamic>.from(entry.value);
          return Question.fromJson(map, id: entry.key.toString());
        })
            .toList();
      } else if (data is Map) {
        // Keyed map: use Firebase keys as questionId
        fetchedQuestions = (data as Map).entries
            .where((entry) => entry.value is Map)
            .map((entry) {
          final id = entry.key.toString();
          final value = entry.value;
          final map = Map<String, dynamic>.from(value as Map);
          return Question.fromJson(map, id: id);
        })
            .toList();
      } else {
        return [];
      }

      fetchedQuestions.shuffle();

      final selectedQuestions = fetchedQuestions.take(desiredCount).toList();
      final remaining = fetchedQuestions.skip(desiredCount).toList();

      // Cache remaining
      final encoded = jsonEncode(remaining.map((q) => q.toJson()).toList());
      await prefs.setString('cached_popular_opinion_questions', encoded);

      return selectedQuestions;
    }

    return [];
  }

  Future<void> clearCachedQuestions() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove specific caches
    await prefs.remove('cached_general_questions');
    await prefs.remove('cached_popular_opinion_questions');

    print('✅ Cache cleared successfully.');
  }

}



