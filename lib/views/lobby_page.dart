import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';
import 'group_game_page.dart';

class LobbyPage extends StatelessWidget {
  final String gameId;
  final String currentPlayerName;

  const LobbyPage({
    required this.gameId,
    required this.currentPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final gameRef = FirebaseDatabase.instance.ref('games/$gameId');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Lobby', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: gameRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final gameName = data['gameName'] ?? '';
          final playersMap = Map<String, dynamic>.from(data['players'] ?? {});
          final player1Data = Map<String, dynamic>.from(playersMap['player1'] ?? {});
          final isPlayer1 = player1Data['name'] == currentPlayerName;

          final currentRound = data['currentRound'] ?? 1;
          final roundKey = 'round$currentRound';
          final roundName = data[roundKey] ?? 'Unknown';

          final gameStarted = data['gameStarted'] == true;

          if (gameStarted && !isPlayer1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => GameViewModel(
                      gameID: gameId,
                      gameName: gameName,
                      currentPlayerName: currentPlayerName,
                      isPlayerOne: isPlayer1
                    )..initializeRounds(roundName: roundName),
                    child: GroupGame(
                      gameID: gameId,
                      gameName: gameName,
                      currentPlayerName: currentPlayerName,
                      isPlayerOne: isPlayer1,
                    ),
                  ),
                ),
              );
            });
          }

          // Extract player list with metadata
          final List<Map<String, dynamic>> playerList = playersMap.entries.map((entry) {
            final playerData = Map<String, dynamic>.from(entry.value);
            return {
              'key': entry.key,
              'name': playerData['name'] ?? 'Unknown',
              'score': playerData['score'] ?? 0,
              'playerImage': playerData['playerImage'],
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game: $gameName',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Players:',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 10),
                ...playerList.map((player) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Image
                        if (player['playerImage'] != null)
                          ClipOval(
                            child: Image.network(
                              player['playerImage'],
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, color: Colors.brown),
                          ),
                        const SizedBox(width: 10),

                        // Name and score
                        Expanded(
                          child: Text(
                            '${player['name']} - Score: ${player['score']}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Spacer(),
                if (isPlayer1)
                  ElevatedButton(
                    onPressed: () {
                      gameRef.update({
                        'allowJoin': false,
                        'gameStarted': true,
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => GameViewModel(
                              gameID: gameId,
                              gameName: gameName,
                              currentPlayerName: currentPlayerName,
                              isPlayerOne: isPlayer1
                            )..initializeRounds(roundName: roundName),
                            child: GroupGame(
                              gameID: gameId,
                              gameName: gameName,
                              currentPlayerName: currentPlayerName,
                              isPlayerOne: isPlayer1,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Start Game'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

