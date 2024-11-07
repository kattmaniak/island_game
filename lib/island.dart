import 'package:flutter/scheduler.dart';

import 'tile.dart';
import 'game.dart';

class Island {
  Island(this._game);
  Game _game;

  List<Tile> tiles = List.empty(growable: true);
  int _averageHeight = 0;
  Ticker? _ticker;
  Duration _currentTime = Duration.zero;
  bool _success = false;
  bool _tapped = false;

  void addTile(Tile tile) {
    tiles.add(tile);
  }

  void calculateAverageHeight() {
    int sum = 0;
    for (var tile in tiles) {
      sum += tile.height;
    }
    _averageHeight = sum ~/ tiles.length;
  }

  int getAverageHeight() {
    return _averageHeight;
  }

  void tapped(double x, double y) {
    if (_game.isFinished() || _tapped) {
      return;
    }
    _tapped = true;
    _game.useAttempt();
    if (_success) _game.setSuccess(true);
    _ticker = Ticker((Duration elapsed) {
      _currentTime = elapsed;
      for (var tile in tiles) {
        tile.setTime(_currentTime);
        tile.setXY(x, y);
      }
      if (_currentTime.inSeconds >= 10) {
        _ticker!.stop();
      }
    });
    _ticker!.start();
  }

  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
  }

  void setSuccess(bool success) {
    this._success = success;
    for (var tile in tiles) {
      tile.setSuccess(success);
    }
  }
}
