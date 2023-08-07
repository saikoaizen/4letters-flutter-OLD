class SessionState {
  final bool? chosenWord;
  final String? secretWord;
  final bool? turn;
  final int? response;
  final bool? gameStart;
  final bool? loading;
  final bool? result;
  final String? guessWord;

  SessionState({
    this.chosenWord,
    this.secretWord,
    this.turn,
    this.response,
    this.gameStart,
    this.loading,
    this.result,
    this.guessWord,
  });
}
