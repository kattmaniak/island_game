import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'island.dart';
import 'tile.dart';
import 'package:perlin/perlin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Island Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  static int tiles_x = 30;
  static int tiles_y = 30;

  Game? game;

  String gameText = "";
  int score = 0;
  int highScore = 0;
  var loading = true;
  var started = false;
  var randmap = false;
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
    game = Game(this);
  }

  Future<void> init() async {
    tiles = List.filled(tiles_x * tiles_y, null);
    gameText = "Attempts left: 3";
    for (var island in islands) {
      island.dispose();
    }
    islands.clear();
    game!.reInit();
    _init().then((value) {
      setState(() {
        loading = false;
      });
    });
  }
  
  Future<String> initMap() async {
    String responseBody = "";
    if(!randmap){
      if(!kIsWeb) {
        var client = HttpClient();
        HttpClientRequest request = await client.getUrl(
            Uri.parse("https://jobfair.nordeus.com/jf24-fullstack-challenge/test"));
        HttpClientResponse response = await request.close();
        responseBody = await response.transform(const Utf8Decoder()).join();
      } else {
        responseBody = await http.read(Uri.parse("https://corsproxy.io/?https%3A%2F%2Fjobfair.nordeus.com%2Fjf24-fullstack-challenge%2Ftest%2F"));
      }
    }else{
      // ignore: unused_local_variable
      try {
        var res2 = await Future.delayed(Duration(milliseconds: 1), () => {""});
      } catch (e) {
        // do nothing
      }
      
      final noise = perlin2d(width: tiles_x~/5, height: tiles_y~/5, frequency: 5, seed: Random().nextInt(2048));
      debugPrint(noise.length.toString());
      for(int i = 0; i < tiles_x; i++){
        for(int j = 0; j < tiles_y; j++){
          double value = noise[i][j];
          int height = (value * 1200).toInt();
          if(height < 200){
            height = 0;
          } else {
            height = height - 200;
          }
          responseBody += "$height ";
        }
        responseBody = responseBody.trim();
        responseBody += "\n";
      }
      responseBody = await responseBody.trim();
    }
    return responseBody;
  }

  Future<void> _init() async {
    String responseBody;
    responseBody = await initMap();

    List<List<int>> map = List.generate(tiles_y, (_) => List.filled(tiles_x, 0));

    List<String> lines = responseBody.split("\n");
    //debugPrint("Lines len ${lines.length}");
    for (int i = 0; i < lines.length; i++) {
      var split = lines[i].split(" ");
      for (int j = 0; j < split.length; j++) {
        map[i][j] = (int.parse(split[j]));
      }
    }

    List<List<bool>> visited = List.generate(tiles_y, (_) => List.filled(tiles_x, false));
    //debugPrint(map.toString());

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
          //debugPrint("Parsed tile at $x, $y with height ${map[x][y]}");
        }
        island.calculateAverageHeight();
        islands.add(island);
        if (max == null || island.getAverageHeight() > max.getAverageHeight()) {
          max = island;
        }
      }
    }
    max!.setSuccess(true);
    game!.setWisland(max);
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Island Game", style: Theme.of(context).textTheme.displayMedium),
            Text("Guess the island with the highest average height", style: Theme.of(context).textTheme.bodyMedium),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FilledButton(
                onPressed: (){
                setState(() {
                  loading = true;
                  started = true;
                });
                init();
              }, child: 
                Text("Play")
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Random maps"),
                Switch(
                  value: randmap, 
                  onChanged: (value){
                    setState(() {
                      randmap = value;
                      if(!randmap){
                        tiles_x = 30;
                        tiles_y = 30;
                      }
                    });
                  }
                ),
              ],
            ),
            if(randmap)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Map size"),
                  Slider(
                    min: 30.0,
                    max: 100.0,
                    divisions: 7,
                    value: tiles_x.toDouble(), 
                    onChanged: (value){
                      setState(() {
                        tiles_x = value.toInt();
                        tiles_y = value.toInt();
                      });
                    }
                  ),
                  Text("${tiles_x}x$tiles_y"),
                ],
              )
          ],
        )
      ),
    );
    }
    if(loading){
      debugPrint("Loading");
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator()
        ),
      );
     }
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    double boxwidth = min(screenWidth, screenHeight) * 0.8;

    double left = (screenWidth - boxwidth) / 2;
    double top = (screenHeight - boxwidth) / 16;
    double right = (screenWidth - boxwidth) / 2;
    double bottom = (screenHeight - boxwidth) / 16;

    return Scaffold(
        body: Center(
      child: ListView(children: <Widget>[
        Padding(
              padding: EdgeInsets.fromLTRB(10, top*4, 10, 0),
              child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Score: $score     "),
            Text("High score: $highScore"),
          ],
              ),
        ),
        GridView.count(
          padding: EdgeInsets.fromLTRB(left, top, right, bottom),
          shrinkWrap: true,
          crossAxisCount: tiles_x,
          children: List.generate(tiles_x * tiles_y, (index) {
            return tiles[index]!;
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(gameText),
            ),
            if(game!.isFinished()) FilledButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(10, 0, 10, 0))
              ),
              onPressed: () {
                setState(() {
                  loading = true;
                });
                init();
              },
              child: Text("Play again")),
            if(game!.isFinished()) TextButton(
              onPressed: () {
                for (var island in islands) {
                  island.dispose();
                }
                game?.setScore(0);
                setState(() {
                  started = false;
                });
              },
              child: Text("Main menu")),
          ],
        ),
      ]),
    ));
  }

  void updateScore(int score) {
    setState(() {
      this.score = score;
    });
  }

  void updateHighScore(int highScore) {
    setState(() {
      this.highScore = highScore;
    });
  }
}
