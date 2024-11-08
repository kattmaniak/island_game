import 'package:flutter/foundation.dart';
import 'package:island_game/island.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Game {
  Game(this.state) {
    _initScore();
  }
  MyHomePageState state;

  Island? _wisland;

  int _attempts = 3;
  bool _finished = false;
  bool _success = false;
  int _highScore = 0;
  int _score = 0;
  int get score => _score;
  int get highScore => _highScore;
  var shared_preferences;

  void reInit() {
    _attempts = 3;
    _finished = false;
    _success = false;
    state.updateScore(_score);
    state.updateText("Attempts left: $_attempts");
    _wisland?.dispose();
    _wisland = null;
  }

  void _initScore() async {
    shared_preferences = await SharedPreferences.getInstance();
    _highScore = shared_preferences.getInt("highscore") ?? 0;
    state.updateHighScore(_highScore);
    debugPrint("init Highscore: $_highScore");
  }

  void setWisland(Island wisland) {
    _wisland = wisland;
  }

  void useAttempt() {
    _attempts--;
    if (_attempts == 0) {
      _finished = true;
      _wisland!.reveal();
      state.updateText("Game over!");
      _score = 0;
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
    _score += 1;
    state.updateScore(_score);
    if(_score > _highScore){
      _highScore = _score;
      shared_preferences.setInt("highscore", _highScore);
      state.updateHighScore(_highScore);
    }
    debugPrint("Highscore: $_highScore");
    debugPrint("Score: $_score");
  }

  bool getSuccess() {
    return _success;
  }

  void setScore(int i) {
    _score = i;
  }
}
