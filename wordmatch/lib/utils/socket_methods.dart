import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/models/game_state.dart';
import 'package:wordmatch/utils/socket_client.dart';
import '../models/session_state.dart';
import '../providers/session_state_provider.dart';
import '../screens/game_page.dart';
import '../providers/game_state_provider.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  //Create room emit
  createRoom(String name) {
    if (name.isNotEmpty) {
      _socketClient.emit('create-room', name);
    }
  }

  //Join room emit
  joinRoom(BuildContext context, String roomCode, String name) {
    if (name.isNotEmpty && roomCode.isNotEmpty) {
      final gameStateNotifier = context.read<GameStateProvider>();
      gameStateNotifier.updateGameState(
        GameState(
          joinloading: true,
        ),
      );
      _socketClient.emit('join-room', {
        'roomCode': roomCode,
        'name': name,
      });
    }
  }

  //Disconnecting to Home
  disconnectToHome(BuildContext context) {
    context.read<GameStateProvider>().reset();
    context.read<SessionStateProvider>().reset();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  //Disconnecting to Join Room
  disconnectToJoinRoom(BuildContext context) {
    GameStateProvider gameStateProvider = context.read<GameStateProvider>();
    GameState gameState = gameStateProvider.gameState;

    gameStateProvider.reset();

    gameStateProvider
        .updateGameState(GameState(playerName: gameState.playerName));

    _socketClient.emit('leave-room', gameState.roomCode);

    Navigator.pop(context);
  }

  //When the opponent leaves the room
  onPlayerLeft(BuildContext context) {
    final gameStateNotifier = context.read<GameStateProvider>();
    _socketClient.on(
      'player-left',
      (name) => {
        gameStateNotifier
            .updateGameState(GameState(opponentName: "", isPartyLeader: true))
      },
    );
  }

  //Wrong roomCode error listener
  roomJoinErrorListener(GlobalKey<ScaffoldState> scaffoldKey) {
    //registered variable makes sure that the snackbar message is only shown once-
    //-Otherwise the number of times the message shows up keeps increasing everytime there's a roomJoinError
    bool registered = false;
    final gameStateNotifier =
        scaffoldKey.currentContext!.read<GameStateProvider>();
    _socketClient.on(
      'roomJoinError',
      (data) => {
        if (registered == false)
          {
            gameStateNotifier.updateGameState(
              GameState(
                createloading: false,
                joinloading: false,
              ),
            ),
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(data),
                duration: const Duration(seconds: 1),
              ),
            ),
            registered = true,
          },
      },
    );
  }

  //After joining a room
  onJoinedRoom(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameStateNotifier = context.read<GameStateProvider>();
      _socketClient.on(
        'joinedRoom',
        (data) {
          gameStateNotifier.updateGameState(
            GameState(
              roomCode: data['roomCode'],
              isPartyLeader: false,
              opponentName: data['opponentName'],
              joinloading: false,
              createloading: false,
            ),
          );
          Navigator.pushNamed(context, '/room-page');
        },
      );
    });
  }

  //After creating a room
  onCreateRoom(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameStateNotifier = context.read<GameStateProvider>();
      _socketClient.on(
        'createdRoom',
        (roomCode) {
          gameStateNotifier.updateGameState(
            GameState(
              roomCode: roomCode,
              isPartyLeader: true,
              opponentName: '',
            ),
          );
          Navigator.pushNamed(context, '/room-page');
        },
      );
    });
  }

  //After opponent joins the room
  onOpponentJoined(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final gameStateNotifier = context.read<GameStateProvider>();

        _socketClient.on(
          'opponentJoined',
          (name) {
            if (gameStateNotifier.gameState.isPartyLeader!) {
              gameStateNotifier.updateGameState(
                GameState(
                  isPartyLeader: true,
                  opponentName: name,
                ),
              );
            }
          },
        );
      },
    );
  }

  //Starting the game (not really)
  startGame(BuildContext context) {
    final gameStateNotifier = context.read<GameStateProvider>();
    _socketClient.emit('start-game', gameStateNotifier.gameState.roomCode);
  }

  //After starting the game
  onGameStart(BuildContext context) {
    _socketClient.on(
      'startedGame',
      (data) {
        // Delay the navigation to the new page using addPostFrameCallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamePage()),
          );
        });
      },
    );
  }

  //Submitting the secret word to the server
  submitSecretWord(BuildContext context, String secretWord) {
    final gameStateNotifier = context.read<GameStateProvider>();

    _socketClient.emit('submit-secret-word', {
      'roomCode': gameStateNotifier.gameState.roomCode,
      'secretWord': secretWord.toLowerCase(),
    });
  }

  //After submitting the secret word
  submittedSecretWordProvider(BuildContext context) {
    final sessionStateNotifier = context.read<SessionStateProvider>();

    _socketClient.on('submitted-secret-word', (_) {
      SessionState session = SessionState(
        chosenWord: true,
        loading: false,
        turn: !sessionStateNotifier.sessionState.turn!,
      );
      sessionStateNotifier.updateSessionState(session);
    });
  }

  //ACTUALLY STARTING THE GAME
  beginSessionProvider(BuildContext context) {
    final gameStateNotifier = context.read<GameStateProvider>();

    final sessionStateNotifier = context.read<SessionStateProvider>();

    _socketClient.on('begin-session', (_) {
      late SessionState session;
      if (gameStateNotifier.gameState.isPartyLeader!) {
        session = SessionState(
          gameStart: true,
          turn: true,
        );
      } else {
        session = SessionState(
          gameStart: true,
          turn: false,
        );
      }
      sessionStateNotifier.updateSessionState(session);
    });
  }

  //Submitting a guess
  submitGuess(BuildContext context, String guess) {
    final sessionStateNotifier = context.read<SessionStateProvider>();

    //preventing multiple submission
    if (sessionStateNotifier.sessionState.loading!) return;

    final gameStateNotifier = context.read<GameStateProvider>();

    SessionState session = SessionState(
      loading: true,
    );
    sessionStateNotifier.updateSessionState(session);

    _socketClient.emit('submit-guess', {
      'roomCode': gameStateNotifier.gameState.roomCode,
      'guess': guess.toLowerCase(),
    });
  }

  //On receiving a guess's response
  guessResponseProvider(BuildContext context) {
    final sessionStateNotifier = context.read<SessionStateProvider>();

    _socketClient.on('guess-response', (data) {
      SessionState session = SessionState(
        loading: false,
        response: data['count'],
        turn: !sessionStateNotifier.sessionState.turn!,
        guessWord: data['guess'].toString().toUpperCase(),
      );
      sessionStateNotifier.updateSessionState(session);
    });
  }

  //On receiving an invalid word
  invalidWordProvider(BuildContext context) {
    final sessionStateNotifier = context.read<SessionStateProvider>();
    SessionState session;
    _socketClient.on(
      'wordSubmitError',
      (data) => {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data),
            duration: const Duration(seconds: 1),
          ),
        ),
        session = SessionState(
          loading: false,
        ),
        sessionStateNotifier.updateSessionState(session),
      },
    );
  }

  // Game Over Listener and handler
  gameOverProvider(BuildContext context) {
    final gameStateNotifier = context.read<GameStateProvider>();
    final sessionStateNotifier = context.read<SessionStateProvider>();
    SessionState session;
    _socketClient.on(
      'game-over',
      (data) {
        session = SessionState(
          result: data == gameStateNotifier.gameState.playerName,
        );
        sessionStateNotifier.updateSessionState(session);
        Navigator.pushNamed(context, '/result-page');
      },
    );
  }
}
