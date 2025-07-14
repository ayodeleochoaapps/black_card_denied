import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../viewmodels/game_view_model.dart';
import 'package:provider/provider.dart';


class GameOverlayPage extends StatefulWidget {
  final GameViewModel gameViewModel;
  final String playerName;
  final bool isPlayerOne;

  const GameOverlayPage({super.key, required this.gameViewModel, required this.playerName, required this.isPlayerOne});

  @override
  State<GameOverlayPage> createState() => _GameOverlayPageState();
}

class _GameOverlayPageState extends State<GameOverlayPage> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();

        // Update Firebase before popping the overlay
        final gameRef = FirebaseDatabase.instance.ref('games/${widget.gameViewModel.gameID}');
        await gameRef.update({'gameStarted': false});

        if (mounted) {
          Navigator.pop(context);
          widget.gameViewModel.startCountdown();
        }

        setState(() {
          _countdown = 0;
        });
      }
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // final gameViewModel = Provider.of<GameViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: GestureDetector(
        onTap: () {}, // disable closing by tapping outside
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.playerName,
                    style: TextStyle(fontSize: 32, color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.gameViewModel.round!.getRoundName(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.gameViewModel.round!.getRoundDescription(),
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Text('Starting in $_countdown...',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}











