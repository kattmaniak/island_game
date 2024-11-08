import 'package:flutter/material.dart';
import 'package:island_game/island.dart';

import 'main.dart';

class Game {
  Game(this.state);
  MyHomePageState state;

  Island? _wisland;

  int _attempts = 3;
  bool _finished = false;
  bool _success = false;

  void setWisland(Island wisland) {
    _wisland = wisland;
  }

  void useAttempt() {
    _attempts--;
    if (_attempts == 0) {
      _finished = true;
      _wisland!.reveal();
      state.updateText("Game over!");
      return;
    }
    state.updateText("Attempts left: $_attempts");
  }

  bool isFinished() {
    return _finished;
  }

  int getAttempts() {
    return _attempts;
  }

  void setSuccess(bool success) {
    _finished = true;
    _success = success;
    state.updateText("You win!");
  }

  bool getSuccess() {
    return _success;
  }
}
