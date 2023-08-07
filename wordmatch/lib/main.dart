import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/models/game_state.dart';
import 'package:wordmatch/screens/join_page.dart';
import 'package:wordmatch/screens/room_page.dart';
import 'package:wordmatch/screens/game_page.dart';
import 'package:wordmatch/providers/game_state_provider.dart';
import 'package:wordmatch/providers/session_state_provider.dart';

import 'screens/result_page.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameStateProvider>(
            create: (_) => GameStateProvider()),
        ChangeNotifierProvider<SessionStateProvider>(
            create: (_) => SessionStateProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'INR',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const NamePage(),
          '/join-page': (context) => const JoinPage(),
          '/room-page': (context) => const RoomPage(),
          '/game-page': (context) => const GamePage(),
          '/result-page': (context) => const ResultPage(),
        },
      ),
    );
  }
}

class NamePage extends StatelessWidget {
  const NamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameStateProvider gameStateNotifier =
        Provider.of<GameStateProvider>(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 220,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Welcome!",
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  cursorWidth: 5,
                  textAlign: TextAlign.left,
                  maxLength: 10,
                  cursorColor: Colors.teal,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontFamily: 'Arial',
                  ),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(77, 162, 233, 193),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: '  Enter your name'),
                  onSubmitted: (value) {
                    value = value.trim();
                    if (value.isEmpty) return;
                    gameStateNotifier
                        .updateGameState(GameState(playerName: value));
                    Navigator.pushNamed(context, "/join-page");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
