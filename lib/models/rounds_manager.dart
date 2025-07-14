import 'package:blackcarddenied/models/round.dart';

class RoundsManager {
  // Private static instance
  static final RoundsManager _instance = RoundsManager._internal();

  // Factory constructor returns the same instance every time
  factory RoundsManager() {
    return _instance;
  }

  // Private constructor
  RoundsManager._internal();

  // Instance fields
  final List<Round> _rounds = [];
  int _currentRoundIndex = 0;

  /// Get current active round
  Round? getCurrentRound() {
    if (_currentRoundIndex < _rounds.length) {
      return _rounds[_currentRoundIndex];
    }
    return null;
  }

  /// Move to next round
  void advanceToNextRound() {
    if (!isFinished()) {
      _currentRoundIndex++;
    }
  }

  /// Add a round to the list
  void addRound(Round round) {
    _rounds.add(round);
  }

  /// Get list of all rounds
  List<Round> getAllRounds() => _rounds;

  /// Check if all rounds are completed
  bool isFinished() => _currentRoundIndex >= _rounds.length;

  /// Get total score across all rounds
  int getTotalScore() {
    return _rounds.fold(0, (sum, round) => sum + round.getScore());
  }

  int getRoundCount() => _rounds.length;

  /// Get a specific round by index
  Round? getRound(int index) {
    if (index >= 0 && index < _rounds.length) {
      return _rounds[index];
    }
    return null;
  }

  /// Get current round index
  int getCurrentRoundIndex() => _currentRoundIndex;

  /// Clear rounds (optional utility)
  void reset() {
    _rounds.clear();
    _currentRoundIndex = 0;
  }
}

