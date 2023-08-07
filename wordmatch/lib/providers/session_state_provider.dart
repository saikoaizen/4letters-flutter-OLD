import 'package:flutter/foundation.dart';
import '../models/session_state.dart';

class SessionStateProvider extends ChangeNotifier {
  SessionState _sessionState = SessionState(
    chosenWord: false,
    response: -1,
    secretWord: '',
    turn: false,
    gameStart: false,
    loading: false,
    result: false,
    guessWord: '',
  );

  SessionState get sessionState => _sessionState;

  void updateSessionState(SessionState newState) {
    SessionState session = SessionState(
      chosenWord: newState.chosenWord ?? _sessionState.chosenWord,
      gameStart: newState.gameStart ?? _sessionState.gameStart,
      loading: newState.loading ?? _sessionState.loading,
      response: newState.response ?? _sessionState.response,
      secretWord: newState.secretWord ?? _sessionState.secretWord,
      turn: newState.turn ?? _sessionState.turn,
      result: newState.result ?? _sessionState.result,
      guessWord: newState.guessWord ?? _sessionState.guessWord,
    );

    _sessionState = session;
    notifyListeners();
  }

  void reset() {
    _sessionState = SessionState(
      chosenWord: false,
      response: -1,
      secretWord: '',
      turn: false,
      gameStart: false,
      loading: false,
      result: false,
      guessWord: '',
    );
  }
}
