import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'island.dart';

// ignore: must_be_immutable
class Tile extends StatefulWidget {
  Tile({super.key, required this.height, this.island}) {
    state = _TileState(height: height, island: island);
  }

  final int height;
  final Island? island;
  _TileState? state;

  void setTime(Duration time) {
    state!.setTime(time);
  }

  void setSuccess(bool success) {
    state!.setSuccess(success);
  }

  void setXY(double x, double y) {
    state!.setXY(x, y);
  }

  @override
  State<Tile> createState() {
    return state!;
  }
}

class _TileState extends State<Tile> {
  _TileState({required this.height, this.island});

  final int height;
  final Island? island;
  Duration currentTime = Duration.zero;
  bool success = false;
  double x = 0;
  double y = 0;
  Offset off = Offset(0, 0);

  void setTime(Duration time) {
    setState(() {
      currentTime = time;
    });
  }

  void setSuccess(bool success) {
    this.success = success;
  }

  @override
  void initState() {
    super.initState();
  }

  void setXY(double x, double y) {
    setState(() {
      this.x = x;
      this.y = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (height <= 0) {
      color = Colors.blue;
    } else if (height <= 200) {
      color = Colors.yellow[(height ~/ 100) * 100 + 100];
    } else if (height <= 400) {
      color = Colors.green[(height ~/ 100) * 100 + 200];
    } else if (height <= 800) {
      color = Colors.grey[(height ~/ 100) * 100];
    } else {
      color = Colors.white;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox box = context.findRenderObject() as RenderBox;
      off = box.localToGlobal(Offset.zero);
    });

    return GestureDetector(
        onTapUp: (details) {
          debugPrint("Tapped at ${details.globalPosition}");
          island?.tapped(details.globalPosition.dx, details.globalPosition.dy);
        },
        child: ShaderBuilder(assetKey: "shaders/tapshader.frag",
            (BuildContext context, FragmentShader shader, _) {
          return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: TilePainter(
                  color: color!,
                  shader: shader,
                  currentTime: currentTime,
                  success: success,
                  x: x,
                  y: y,
                  off: off));
        }));
  }
}

class TilePainter extends CustomPainter {
  TilePainter(
      {required this.color,
      required this.shader,
      required this.currentTime,
      required this.success,
      required this.x,
      required this.y,
      required this.off});

  Color color;
  FragmentShader shader;
  Duration currentTime;
  bool success;
  double x;
  double y;
  Offset off;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, color.red / 255);
    shader.setFloat(1, color.green / 255);
    shader.setFloat(2, color.blue / 255);
    shader.setFloat(3, color.alpha / 255);

    shader.setFloat(4, x);
    shader.setFloat(5, y);

    shader.setFloat(6, currentTime.inMilliseconds / 1000);

    shader.setFloat(7, success ? 1 : 0);

    shader.setFloat(8, off.dx);
    shader.setFloat(9, off.dy);

    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
