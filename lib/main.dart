import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'island.dart';
import 'tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static final int tiles_x = 30;
  static final int tiles_y = 30;

  Game? game;

  String gameText = "";
  var loading = true;
  var islands = <Island>[];
  List<Tile?> tiles = List.filled(tiles_x * tiles_y, null);

  void updateText(String text) {
    setState(() {
      gameText = text;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    gameText = "Attempts left: 3";
    game = Game(this);
    for (var island in islands) {
      island.dispose();
    }
    _init().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> _init() async {
    String responseBody;
    if(!kIsWeb) {
      var client = HttpClient();
      HttpClientRequest request = await client.getUrl(
          Uri.parse("https://jobfair.nordeus.com/jf24-fullstack-challenge/test"));
      HttpClientResponse response = await request.close();
      responseBody = await response.transform(const Utf8Decoder()).join();
    } else {
      responseBody = await http.read(Uri.parse("https://corsproxy.io/?https%3A%2F%2Fjobfair.nordeus.com%2Fjf24-fullstack-challenge%2Ftest%2F"));
    }

    List<List<int>> map = List.generate(30, (_) => List.filled(30, 0));

    List<String> lines = responseBody.split("\n");
    debugPrint("Lines len ${lines.length}");
    for (int i = 0; i < lines.length; i++) {
      var split = lines[i].split(" ");
      for (int j = 0; j < split.length; j++) {
        map[i][j] = (int.parse(split[j]));
      }
    }

    List<List<bool>> visited = List.generate(30, (_) => List.filled(30, false));
    debugPrint(map.toString());

    islands.clear();
    Island? max;

    for (int i = 0; i < tiles_x; i++) {
      for (int j = 0; j < tiles_y; j++) {
        if (visited[i][j]) {
          continue;
        }
        if (map[i][j] == 0) {
          visited[i][j] = true;
          Tile tile = Tile(height: 0, island: null);
          tiles[i * tiles_x + j] = tile;
          continue;
        }
        var island = Island(game!);
        var queue = <List<int>>[];
        queue.add([i, j]);
        while (queue.isNotEmpty) {
          var current = queue.removeAt(0);
          var x = current[0];
          var y = current[1];
          if (x < 0 || x >= tiles_x || y < 0 || y >= tiles_y) {
            continue;
          }
          if (visited[x][y]) {
            continue;
          }
          if (map[x][y] == 0) {
            continue;
          }
          visited[x][y] = true;
          Tile tile = Tile(height: map[x][y], island: island);
          island.tiles.add(tile);
          tiles[x * tiles_x + y] = tile;
          queue.add([x + 1, y]);
          queue.add([x - 1, y]);
          queue.add([x, y + 1]);
          queue.add([x, y - 1]);
          debugPrint("Parsed tile at $x, $y with height ${map[x][y]}");
        }
        island.calculateAverageHeight();
        islands.add(island);
        if (max == null || island.getAverageHeight() > max.getAverageHeight()) {
          max = island;
        }
      }
    }
    max!.setSuccess(true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    double boxwidth = min(screenWidth, screenHeight) * 0.8;

    double left = (screenWidth - boxwidth) / 2;
    double top = (screenHeight - boxwidth) / 2;
    double right = (screenWidth - boxwidth) / 2;
    double bottom = (screenHeight - boxwidth) / 8;

    return Scaffold(
        body: Center(
      child: ListView(children: <Widget>[
        GridView.count(
          padding: EdgeInsets.fromLTRB(left, top, right, bottom),
          shrinkWrap: true,
          crossAxisCount: 30,
          children: List.generate(tiles_x * tiles_y, (index) {
            return tiles[index]!;
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(gameText),
            gameText == "You win!" || gameText == "Game over!"
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      init();
                    },
                    child: Text("Restart"))
                : Text("")
          ],
        ),
      ]),
    ));
  }
}
