import 'package:flutter/material.dart';
import 'views/group_game_page.dart';
import 'viewmodels/game_view_model.dart';
import 'package:provider/provider.dart';
import 'services/navigation_service.dart';
import 'views/group_select_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blackcarddenied/firebase_options.dart';



void main() async {
  /*WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(); // 👈 If this hangs or throws, UI gets stuck
  } catch (e) {
    print('🔥 Firebase initialization error: $e');
  }*/

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
        navigatorKey: navigationService.navigatorKey,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Black Card Denied', style: TextStyle(
          color: Colors.white
        ),),
        // The back button will appear automatically here
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Optional: Center vertically
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => GameViewModel(gameID: "-OTmcKfSumDLp0nKYpUb", gameName: "WNBA", currentPlayerName: "Clark", isPlayerOne: true),
                      child: const GroupGame(
                        gameID: "-OTmcKfSumDLp0nKYpUb",
                        gameName: "WNBA",
                        currentPlayerName: "Clark",
                        isPlayerOne: true,
                      ),
                    ),
                  ),
                );
              },
              child: Text("Solo Round"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                navigationService.navigateTo(GroupSelectPage());
              },
              child: Text("Group Round"),
            ),
          ],
        ),
      ),
    );
  }
}
