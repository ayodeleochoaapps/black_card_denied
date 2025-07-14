import 'package:blackcarddenied/viewmodels/setup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lobby_page.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'lobby_page.dart';

class JoinGamePage extends StatefulWidget {
  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SetupViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Join Game'),
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
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? ClipOval(
                child: Image.file(
                  _image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
                  : const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            const Spacer(),

            // Join Game Button
            ElevatedButton(
              onPressed: () async {
                final gameId = await viewModel.joinGameInFirebase(imageFile: _image);
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
              child: const Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}
