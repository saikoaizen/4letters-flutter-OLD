import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/utils/socket_methods.dart';
import '../providers/game_state_provider.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Room();
  }
}

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final SocketMethods _socketMethods = SocketMethods();
  late BuildContext c = context;

  @override
  void initState() {
    super.initState();
    c = context;
  }

  @override
  Widget build(BuildContext context) {
    _socketMethods.onPlayerLeft(context);
    _socketMethods.onGameStart(context);
    return Consumer<GameStateProvider>(
      builder: (context, gameStateNotifier, _) {
        if (gameStateNotifier.gameState.isPartyLeader == true) {
          _socketMethods.onOpponentJoined(c);
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('WordMatch!'),
            leading: BackButton(
              onPressed: () {
                _socketMethods.disconnectToJoinRoom(context);
              },
            ),
          ),
          body: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 150),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Room Code: ${gameStateNotifier.gameState.roomCode}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                                  text: gameStateNotifier.gameState.roomCode
                                      .toString()))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Room Code Copied!")));
                          });
                        },
                        icon: const Icon(Icons.copy),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${gameStateNotifier.gameState.playerName}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'INR',
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 40,
                              ),
                              gameStateNotifier.gameState.isPartyLeader!
                                  ? const Icon(
                                      Icons.child_care_outlined,
                                      size: 40,
                                      color: Colors.blueAccent,
                                    )
                                  : const SizedBox(),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.teal,
                      thickness: 10,
                    ),
                    Visibility(
                      visible:
                          gameStateNotifier.gameState.opponentName != null &&
                              gameStateNotifier.gameState.opponentName != '',
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${gameStateNotifier.gameState.opponentName}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'INR',
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 40,
                                ),
                                gameStateNotifier.gameState.isPartyLeader!
                                    ? const SizedBox()
                                    : const Icon(
                                        Icons.child_care_outlined,
                                        size: 40,
                                        color: Colors.blueAccent,
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: gameStateNotifier.gameState.opponentName != null &&
                    gameStateNotifier.gameState.opponentName != '' &&
                    gameStateNotifier.gameState.isPartyLeader == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      _socketMethods.startGame(context);
                    },
                    child: const Text('Start Game!'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
