import 'tile.dart';

class Island {
  List<Tile> tiles = List.empty(growable: true);

  void addTile(Tile tile) {
    tiles.add(tile);
  }

  void tapped() {}
}

