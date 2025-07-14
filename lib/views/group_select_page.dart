import 'package:blackcarddenied/viewmodels/setup_view_model.dart';
import 'package:blackcarddenied/views/create_game_page.dart';
import 'package:blackcarddenied/views/join_game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/navigation_service.dart';

class GroupSelectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, // 👈 changes the back button color
        ),
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
                      create: (_) => SetupViewModel(),
                      child: CreateGamePage(),
                    ),
                  ),
                );
              },
              child: Text("Create Game"),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => SetupViewModel(),
                      child: JoinGamePage(),
                    ),
                  ),
                );
              },
              child: Text("Join Game"),
            ),
          ],
        ),
      ),
    );
  }
}
