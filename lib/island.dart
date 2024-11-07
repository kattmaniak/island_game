import 'package:flutter/scheduler.dart';

import 'tile.dart';
import 'game.dart';

class Island {
  Island(this.game);
  Game game;

  List<Tile> tiles = List.empty(growable: true);
  int averageHeight = 0;
  Ticker? ticker;
  Duration currentTime = Duration.zero;
  bool success = false;

  void addTile(Tile tile) {
    tiles.add(tile);
  }

  void calculateAverageHeight() {
    int sum = 0;
    for (var tile in tiles) {
      sum += tile.height;
    }
    averageHeight = sum ~/ tiles.length;
  }

  int getAverageHeight() {
    return averageHeight;
  }

  void tapped(double x, double y) {
    if (game.isFinished()) {
      return;
    }
    game.useAttempt();
    if (success) game.setSuccess(true);
    ticker = Ticker((Duration elapsed) {
      currentTime = elapsed;
      for (var tile in tiles) {
        tile.setTime(currentTime);
        tile.setXY(x, y);
      }
      if (currentTime.inSeconds >= 10) {
        ticker!.stop();
      }
    });
    ticker!.start();
  }

  void dispose() {
    ticker?.stop();
    ticker?.dispose();
  }

  void setSuccess(bool success) {
    this.success = success;
    for (var tile in tiles) {
      tile.setSuccess(success);
    }
  }
}
