import 'package:flutter/material.dart';
import 'island.dart';

class Tile extends StatelessWidget {
  const Tile({super.key, required this.height, required this.size, required this.island});

  final int height;
  final int size;
  final Island island;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (height < 0) {
      color = Colors.blue;
    } else if (height < 200) {
      color = Colors.yellow[(height~/100)*100];
    } else if (height < 400) {
      color = Colors.green[(height~/100)*100];
    } else if (height < 800) {
      color = Colors.grey[(height~/100)*100-300];
    } else {
      color = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        island.tapped();
      },
      child: Container(
      color: color,
      width: size.toDouble(),
      height: size.toDouble(),
    )
    );
  }
}