import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/providers/game_state_provider.dart';
import 'package:wordmatch/utils/socket_methods.dart';
import '../models/game_state.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({
    Key? key,
  }) : super(key: key);

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  final SocketMethods _socketMethods = SocketMethods();
  late TextEditingController _roomCodeController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _roomCodeController = TextEditingController();
    _socketMethods.onJoinedRoom(context);
    _socketMethods.onCreateRoom(context);
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  //join room submit handler
  joinRoomSubmit(GameStateProvider gameStateNotifier) {
    if (gameStateNotifier.gameState.createloading == false &&
        gameStateNotifier.gameState.joinloading == false) {
      _socketMethods.joinRoom(
        context,
        _roomCodeController.text,
        gameStateNotifier.gameState.playerName!,
      );
      _socketMethods.roomJoinErrorListener(_scaffoldKey);
    }
  }

  //create room handler
  createRoomSubmit(GameStateProvider gameStateNotifier) {
    print(gameStateNotifier.gameStateAsString);
    if (gameStateNotifier.gameState.createloading == false &&
        gameStateNotifier.gameState.joinloading == false) {
      _socketMethods.createRoom(gameStateNotifier.gameState.playerName!);
      gameStateNotifier.updateGameState(GameState(createloading: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    GameStateProvider gameStateNotifier =
        Provider.of<GameStateProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('WordMatch!'),
        leading: BackButton(
          onPressed: () {
            _socketMethods.disconnectToHome(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: gameStateNotifier.gameState.createloading!
                  ? const SpinKitCircle(
                      color: Colors.teal,
                      size: 50.0,
                    )
                  : ElevatedButton(
                      onPressed: () {
                        createRoomSubmit(gameStateNotifier);
                      },
                      child: const Text('Create New Room'),
                    ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(top: 100, bottom: 10),
              child: Text(
                "ROOM CODE",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _roomCodeController,
                onSubmitted: (value) => {joinRoomSubmit(gameStateNotifier)},
                autofocus: false,
                cursorWidth: 5,
                textAlign: TextAlign.center,
                maxLength: 6,
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
                ),
              ),
            ),
            gameStateNotifier.gameState.joinloading!
                ? const SpinKitCircle(
                    color: Colors.teal,
                    size: 50.0,
                  )
                : ElevatedButton(
                    child: const Text('Join Room'),
                    onPressed: () {
                      joinRoomSubmit(gameStateNotifier);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
