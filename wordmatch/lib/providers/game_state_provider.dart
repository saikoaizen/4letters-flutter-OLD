import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

class GameStateProvider extends ChangeNotifier {
  GameState _gameState = GameState(
    playerName: '',
    opponentName: '',
    roomCode: '',
    isPartyLeader: false,
    createloading: false,
    joinloading: false,
  );

  GameState get gameState => _gameState;

  void updateGameState(GameState newState) {
    GameState game = GameState(
      playerName: newState.playerName ?? _gameState.playerName,
      opponentName: newState.opponentName ?? _gameState.opponentName,
      roomCode: newState.roomCode ?? _gameState.roomCode,
      isPartyLeader: newState.isPartyLeader ?? _gameState.isPartyLeader,
      createloading: newState.createloading ?? _gameState.createloading,
      joinloading: newState.joinloading ?? _gameState.joinloading,
    );

    _gameState = game;
    notifyListeners();
  }

  void reset() {
    _gameState = GameState(
      playerName: '',
      opponentName: '',
      roomCode: '',
      isPartyLeader: false,
      createloading: false,
      joinloading: false,
    );
  }

  String get gameStateAsString {
    return '''
    Player Name: ${_gameState.playerName}
    Opponent Name: ${_gameState.opponentName}
    Room Code: ${_gameState.roomCode}
    Is Party Leader: ${_gameState.isPartyLeader}
    Create Loading: ${_gameState.createloading}
    Join Loading: ${_gameState.joinloading}
    ''';
  }
}
