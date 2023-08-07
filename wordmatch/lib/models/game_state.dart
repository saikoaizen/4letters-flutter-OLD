class GameState {
  final String? playerName;
  final String? opponentName;
  final String? roomCode;
  final bool? isPartyLeader;
  final bool? createloading;
  final bool? joinloading;

  GameState({
    this.playerName,
    this.opponentName,
    this.roomCode,
    this.isPartyLeader,
    this.createloading,
    this.joinloading,
  });
}
