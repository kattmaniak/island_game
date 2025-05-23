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

  void reveal() {
    for (var tile in tiles) {
      tile.setXY(0, 0);
    }
    _ticker = Ticker((Duration elapsed) {
      if(_currentTime.inSeconds < elapsed.inSeconds){
        if(elapsed.inMilliseconds % 1000 < 500){
          for (var tile in tiles) {
            tile.setTime(Duration(seconds: 1000));
          }
        } else {
          for (var tile in tiles) {
            tile.setTime(Duration.zero);
            _currentTime = elapsed;
          }
        }
      }
    });
    _ticker!.start();
  }

  void tapped(double x, double y) {
    if (_game.isFinished() || _tapped) {
      return;
    }
    _tapped = true;
    if (_success) {
      _game.setSuccess(true);
    } else {
      _game.useAttempt();
    }
    for (var tile in tiles) {
      tile.setXY(x, y);
    }
    _ticker = Ticker((Duration elapsed) {
      _currentTime = elapsed;
      for (var tile in tiles) {
        tile.setTime(_currentTime);
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
    tiles.clear();
  }

  void setSuccess(bool success) {
    this._success = success;
    for (var tile in tiles) {
      tile.setSuccess(success);
    }
  }
}
