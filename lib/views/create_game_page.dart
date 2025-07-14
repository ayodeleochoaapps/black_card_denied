import 'package:blackcarddenied/viewmodels/setup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lobby_page.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/setup_view_model.dart';
import 'lobby_page.dart';

class CreateGamePage extends StatefulWidget {
  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  File? _image;

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Game'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game Name Field
            TextField(
              controller: viewModel.gameNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Game Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Player Name Field
            TextField(
              controller: viewModel.playerController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Take Picture Button
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: Icon(Icons.camera_alt),
              label: Text('Take a Selfie'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 10),

            // Image Preview
            if (_image != null)
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                ),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),

            Spacer(),

            // Create Game Button
            ElevatedButton(
              onPressed: () async {
                final gameId = await viewModel.createGameInFirebase(imageFile: _image);
                if (gameId == null) return;

                final currentPlayerName = viewModel.playerController.text.trim();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LobbyPage(
                      gameId: gameId,
                      currentPlayerName: currentPlayerName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Create Game'),
            ),
          ],
        ),
      ),
    );
  }
}


