import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/providers/game_state_provider.dart';
import 'package:wordmatch/providers/session_state_provider.dart';

import '../main.dart';
import '../models/session_state.dart';
import '../utils/socket_methods.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.submittedSecretWordProvider(context);
    _socketMethods.beginSessionProvider(context);
    _socketMethods.invalidWordProvider(context);
  }

  @override
  Widget build(BuildContext context) {
    final sessionStateNotifier = Provider.of<SessionStateProvider>(context);
    return sessionStateNotifier.sessionState.chosenWord!
        ? const PlayRoom()
        : const GetSecretWord();
  }
}

//Helper class for capitalizing the letters as we type in the input field
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class GetSecretWord extends StatefulWidget {
  const GetSecretWord({super.key});

  @override
  State<GetSecretWord> createState() => _GetSecretWordState();
}

class _GetSecretWordState extends State<GetSecretWord> {
  final SocketMethods _socketMethods = SocketMethods();
  final TextEditingController _secretWordController = TextEditingController();
  bool _passwordVisibile = false;

  submitSecretWord(SessionStateProvider sessionStateNotifier) {
    //
    //VALIDATE THE WORD
    //

    if (sessionStateNotifier.sessionState.loading == false) {
      SessionState session = SessionState(
        chosenWord: false,
        loading: true,
        secretWord: _secretWordController.text,
      );
      sessionStateNotifier.updateSessionState(session);

      _socketMethods.submitSecretWord(
        context,
        _secretWordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionStateNotifier = Provider.of<SessionStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WordMatch!'),
        leading: CloseButton(
          onPressed: () {
            _socketMethods.disconnectToHome(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NamePage()),
            );
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          height: 200,
          width: 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sessionStateNotifier.sessionState.loading!
                  ? const SpinKitCircle(
                      color: Colors.teal,
                      size: 50.0,
                    )
                  : TextField(
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      controller: _secretWordController,
                      textCapitalization: TextCapitalization.characters,
                      obscureText: !_passwordVisibile,
                      autofocus: true,
                      cursorWidth: 5,
                      textAlign: TextAlign.left,
                      maxLength: 4,
                      cursorColor: Colors.teal,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontFamily: 'Arial',
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          padding: const EdgeInsetsDirectional.only(end: 12),
                          onPressed: () {
                            setState(() {
                              _passwordVisibile = !_passwordVisibile;
                            });
                          },
                          icon: _passwordVisibile
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(77, 162, 233, 193),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        hintText: '  SECRET WORD',
                      ),
                      onSubmitted: (value) {
                        submitSecretWord(sessionStateNotifier);
                      },
                    ),
              ElevatedButton(
                onPressed: () {
                  submitSecretWord(sessionStateNotifier);
                },
                child: const Text('DONE!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayRoom extends StatefulWidget {
  const PlayRoom({super.key});

  @override
  State<PlayRoom> createState() => PlayRoomState();
}

class PlayRoomState extends State<PlayRoom> {
  final SocketMethods _socketMethods = SocketMethods();
  final TextEditingController _guessWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _socketMethods.guessResponseProvider(context);
    _socketMethods.gameOverProvider(context);
  }

  @override
  Widget build(BuildContext context) {
    final sessionStateNotifier = Provider.of<SessionStateProvider>(context);
    final gameStateNotifier = context.read<GameStateProvider>();

    return sessionStateNotifier.sessionState.gameStart!
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: CloseButton(
                onPressed: () {
                  _socketMethods.disconnectToHome(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 200),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sessionStateNotifier.sessionState.turn!
                                ? "Your Turn  "
                                : "${gameStateNotifier.gameState.opponentName}'s Turn  ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: sessionStateNotifier.sessionState.turn!
                                  ? Colors.blue
                                  : Colors.red,
                            ),
                          ),
                          !sessionStateNotifier.sessionState.turn!
                              ? const SpinKitCircle(
                                  color: Colors.red,
                                  size: 50.0,
                                )
                              : const Text(''),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        sessionStateNotifier.sessionState.loading!
                            ? SpinKitCircle(
                                color: sessionStateNotifier.sessionState.turn!
                                    ? Colors.blue
                                    : Colors.red,
                                size: 50.0,
                              )
                            : Text(
                                sessionStateNotifier.sessionState.response != -1
                                    ? '${sessionStateNotifier.sessionState.guessWord!} matched ${sessionStateNotifier.sessionState.response!} letters'
                                    : '^_^',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  color: sessionStateNotifier.sessionState.turn!
                                      ? Colors.blue
                                      : Colors.red,
                                ),
                              ),
                        const Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 40),
                          child: Divider(),
                        ),
                        TextField(
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]')),
                          ],
                          enabled: sessionStateNotifier.sessionState.turn,
                          controller: _guessWordController,
                          textCapitalization: TextCapitalization.characters,
                          autofocus: true,
                          cursorWidth: 5,
                          textAlign: TextAlign.center,
                          maxLength: 4,
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
                            hintText: '',
                          ),
                          onSubmitted: (value) {
                            if (sessionStateNotifier.sessionState.turn!) {
                              _socketMethods.submitGuess(
                                context,
                                _guessWordController.text,
                              );
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (sessionStateNotifier.sessionState.turn!) {
                              _socketMethods.submitGuess(
                                context,
                                _guessWordController.text,
                              );
                            }
                          },
                          style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(100, 50)),
                          ),
                          child: const Text(
                            'Guess!',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: CloseButton(
                onPressed: () {
                  _socketMethods.disconnectToHome(context);
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/join-page'),
                  );
                },
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 107, 196, 237),
            body: Center(
              child: Text(
                '^_^ Waiting for ${gameStateNotifier.gameState.opponentName.toString().toUpperCase()} to submit their word...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          );
  }
}
