import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../viewmodels/game_view_model.dart';
import 'group_game_page.dart';
import 'package:provider/provider.dart';
import '../models/rounds_manager.dart';

class ResultsPage extends StatelessWidget {
  final String gameID;
  final String gameName;
  final String currentPlayerName;
  final bool isPlayerOne;

  const ResultsPage({
    super.key,
    required this.gameID,
    required this.gameName,
    required this.currentPlayerName,
    required this.isPlayerOne,
  });

  @override
  Widget build(BuildContext context) {
    final gameRef = FirebaseDatabase.instance.ref('games/$gameID');
    String roundName = "";
    final roundsManager = RoundsManager();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
            'Game Results', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: gameRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final gameData = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);
          final currentRound = gameData['currentRound'];
          final roundKey = 'round$currentRound';
          roundName = gameData[roundKey] ?? 'Unknown Round';

          final gameHasStarted = gameData['gameStarted'] == true;
          final playersMap = Map<String, dynamic>.from(gameData['players']);

          if (gameHasStarted) {
            roundsManager.advanceToNextRound();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => GameViewModel(
                        gameID: gameID,
                        gameName: gameName,
                        currentPlayerName: currentPlayerName,
                        isPlayerOne: isPlayerOne
                    )..initializeRounds(roundName: roundName),
                    child: GroupGame(
                      gameID: gameID,
                      gameName: gameName,
                      currentPlayerName: currentPlayerName,
                      isPlayerOne: isPlayerOne,
                    ),
                  ),
                ),
              );
            });
          }

          final allPlayersFinished = playersMap.values.every((player) {
            final data = Map<String, dynamic>.from(player as Map);
            return data['roundCompleted'] == true;
          });

          final List<Map<String, dynamic>> players = playersMap.entries.map((
              entry) {
            final playerData = Map<String, dynamic>.from(entry.value);
            return {
              'key': entry.key,
              'name': playerData['name'] ?? 'Unknown',
              'score': playerData['score'] ?? 0,
              'playerImage': playerData['playerImage'],
              'roundName': roundName,
            };
          }).toList();

          players.sort((a, b) =>
              (b['score'] as int).compareTo(a['score'] as int));

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (player['playerImage'] != null)
                          ClipOval(
                            child: Image.network(
                              player['playerImage'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, color: Colors.brown),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '${player['name']} - Score: ${player['score']}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // ✅ Conditionally show FAB
              if (isPlayerOne && allPlayersFinished)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      roundsManager.advanceToNextRound();
                      // Set gameStarted to true again (optional)
                       await gameRef.update({'gameStarted': true});

                      // Reset current player's roundCompleted
                      final playerEntry = playersMap.entries.firstWhere(
                            (e) =>
                        Map<String, dynamic>.from(e.value)['name'] ==
                            currentPlayerName,
                        orElse: () => throw Exception("Player not found"),
                      );
                      await gameRef
                          .child('players/${playerEntry.key}')
                          .update({'roundCompleted': false});

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChangeNotifierProvider(
                                create: (_) =>
                                GameViewModel(
                                  gameID: gameID,
                                  gameName: gameName,
                                  currentPlayerName: currentPlayerName,
                                  isPlayerOne: isPlayerOne,
                                )
                                  ..initializeRounds(roundName: roundName),
                                child: GroupGame(
                                  gameID: gameID,
                                  gameName: gameName,
                                  currentPlayerName: currentPlayerName,
                                  isPlayerOne: isPlayerOne,
                                ),
                              ),
                        ),
                      );
                    },
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next Round'),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}




