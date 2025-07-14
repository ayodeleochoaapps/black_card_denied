import 'package:blackcarddenied/viewmodels/game_view_model.dart';
import 'package:blackcarddenied/views/game_overlay_page.dart';
import 'package:blackcarddenied/views/results_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupGame extends StatefulWidget {
  final String gameID;
  final String gameName;
  final String currentPlayerName;
  final bool isPlayerOne;

  const GroupGame({
    Key? key,
    required this.gameID,
    required this.gameName,
    required this.currentPlayerName,
    required this.isPlayerOne
  }) : super(key: key);

  @override
  State<GroupGame> createState() => _GroupGameState();
}

class _GroupGameState extends State<GroupGame> {
  late final String gameName;
  late final String currentPlayerName;
  late final bool isPlayerOne;

  @override
  void initState() {
    super.initState();
    gameName = widget.gameName;
    currentPlayerName = widget.currentPlayerName;
    isPlayerOne = widget.isPlayerOne;

    // Wait until after build context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

      // await gameViewModel.initializeRounds();

      // Show overlay after initialization is done
      showOverlayPage(context, gameViewModel);
    });
  }

  void showOverlayPage(BuildContext context, GameViewModel gameViewModel) {
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => GameOverlayPage(gameViewModel: gameViewModel,
            playerName: currentPlayerName, isPlayerOne: isPlayerOne),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context);
    final gameData = gameViewModel.gameData;

/*    void navigateToResultsPage(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResultsPage()),
      );
    }*/

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.white, // 👈 changes the back button color
        ),
        title: Text('Black Card Denied', style: TextStyle(
            color: Colors.white
        ),),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  gameData?.roundName ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'mikado_bold',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    gameData?.currentQuestion ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'bartone',
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              Consumer<GameViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: viewModel.timeRemaining / 100, // Must be a getter that updates
                        backgroundColor: Colors.grey[300],
                        color: Colors.amber,
                        minHeight: 14,
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Points:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mikado_bold',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          gameData?.currentPointTotal.toString() ?? '0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mikado_bold',
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      gameData?.currentCategory.toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'mikado_bold',
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...[
                gameData?.answerA,
                gameData?.answerB,
                gameData?.answerC,
                gameData?.answerD
              ].asMap().entries.map(
                    (entry) {
                  final answerIndex = entry.key;
                  final answer = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: answer != null
                          ? () {
                        gameViewModel.checkAnswer(answer, answerIndex); // ← pass index
                        gameViewModel.startCountdown();
                      }
                          : null,
                      child: Text(
                        answer ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'bartone',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Current Score:',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'mikado_bold',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gameData?.currentScore.toString() ?? '0',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'mikado_bold',
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}




