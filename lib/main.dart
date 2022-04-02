import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dashadvance/bridge_generated.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _width = 240.0;
const _height = 160.0;
const _primaryColor = Color(0xFF868FD0);
const _buttonColor = Color(0xFFD7CFE1);
const _directionColor = Color(0xFFD7CFE1);
const _gbaColor = Color(0xFF635A9B);
const _seColor = Color(0xFFD7CFE1);
const _paddingColor = Color(0xFF010A26);
const _screenColor = Color(0xFF71716F);
const _appBarColor = Color(0xFF212C4D);

const base = 'rgba';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
late final api = RgbaImpl(dylib);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final parentRx = ReceivePort();

  Isolate.spawn(_launchNes, parentRx.sendPort);

  ValueNotifier<ui.Image?> image = ValueNotifier(null);
  ValueNotifier<int> fps = ValueNotifier(0);
  SendPort? childTx;

  parentRx.listen((e) {
    if (e is SendPort) {
      childTx = e;
    }

    if (e is RenderFrameEvent) {
      ui.decodeImageFromPixels(e.frame, 240, 160, ui.PixelFormat.rgba8888,
          (result) {
        image.value = result;
      });
    }

    if (e is FpsUpdateEvent) {
      fps.value = e.fps;
    }
  });

  runApp(MyApp(
    image: image,
    fps: fps,
    onRomSelected: (bytes) {
      childTx?.send(FileSelectedEvent(bytes));
    },
    onKeyPressed: (key) {
      childTx?.send(KeyPressedEvent(key));
    },
    onKeyReleased: (key) {
      childTx?.send(KeyReleasedEvent(key));
    },
  ));
}

bool _ready = false;

void _launchNes(SendPort parentTx) async {
  final childRx = ReceivePort();

  parentTx.send(childRx.sendPort);

  childRx.listen((message) async {
    if (message is FileSelectedEvent) {
      await api.loadRom(bytes: message.bytes);
      await api.reset(skipBios: false);
      _ready = true;
    }

    if (!_ready) return;

    if (message is KeyPressedEvent) {
      await api.keyPress(key: message.key);
    }

    if (message is KeyReleasedEvent) {
      await api.keyRelease(key: message.key);
    }
  });

  var prevDateTime = DateTime.now();
  var frameCount = 0;
  var fpsTotal = 0.0;
  var sleep = const Duration(milliseconds: 16);

  while (true) {
    if (_ready) {
      final pixels = await api.render();

      parentTx.send(RenderFrameEvent(pixels));
    }

    frameCount += 1;

    await Future.delayed(sleep);

    final current = DateTime.now();
    final elapsed = current.difference(prevDateTime);
    final fps = (1000 / elapsed.inMilliseconds).clamp(0, 80);

    sleep = Duration(
      milliseconds: max((sleep.inMilliseconds + (fps - 60.0)).floor(), 0),
    );

    fpsTotal += fps;

    if (frameCount >= 60) {
      parentTx.send(FpsUpdateEvent((fpsTotal / frameCount).floor()));

      frameCount = 0;
      fpsTotal = 0;
    }

    prevDateTime = current;
  }
}

class FpsUpdateEvent {
  FpsUpdateEvent(this.fps);

  final int fps;
}

class RenderFrameEvent {
  RenderFrameEvent(this.frame);

  final Uint8List frame;
}

class FileSelectedEvent {
  FileSelectedEvent(this.bytes);

  final Uint8List bytes;
}

class KeyPressedEvent {
  KeyPressedEvent(this.key);

  final KeyType key;
}

class KeyReleasedEvent {
  KeyReleasedEvent(this.key);

  final KeyType key;
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.image,
    required this.fps,
    required this.onRomSelected,
    required this.onKeyPressed,
    required this.onKeyReleased,
  }) : super(key: key);

  final ValueNotifier<int> fps;
  final ValueNotifier<ui.Image?> image;
  final void Function(Uint8List) onRomSelected;
  final void Function(KeyType) onKeyPressed;
  final void Function(KeyType) onKeyReleased;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DASH Boy Advance',
      theme: ThemeData(
        primaryColor: _primaryColor,
        canvasColor: _paddingColor,
      ),
      home: MyHomePage(
        title: 'DASH Boy Advance',
        fps: fps,
        image: image,
        onRomSelected: onRomSelected,
        onKeyPressed: onKeyPressed,
        onKeyReleased: onKeyReleased,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.fps,
    required this.image,
    required this.onRomSelected,
    required this.onKeyPressed,
    required this.onKeyReleased,
  }) : super(key: key);

  final String title;
  final ValueNotifier<int> fps;
  final ValueNotifier<ui.Image?> image;
  final void Function(Uint8List) onRomSelected;
  final void Function(KeyType) onKeyPressed;
  final void Function(KeyType) onKeyReleased;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final _keyToKeyTypeMap = {
    LogicalKeyboardKey.keyZ: KeyType.A,
    LogicalKeyboardKey.keyX: KeyType.B,
    LogicalKeyboardKey.keyV: KeyType.Start,
    LogicalKeyboardKey.keyC: KeyType.Select,
    LogicalKeyboardKey.arrowUp: KeyType.Up,
    LogicalKeyboardKey.arrowDown: KeyType.Down,
    LogicalKeyboardKey.arrowRight: KeyType.Right,
    LogicalKeyboardKey.arrowLeft: KeyType.Left,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor,
        foregroundColor: _primaryColor,
        title: Text(widget.title,
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            )),
      ),
      body: KeyboardListener(
        onKeyEvent: (key) {
          final joypadKey = _keyToKeyTypeMap[key.logicalKey];
          if (joypadKey == null) return;

          if (key is KeyDownEvent) {
            widget.onKeyPressed(joypadKey);
          }
          if (key is KeyUpEvent) {
            widget.onKeyReleased(joypadKey);
          }
        },
        focusNode: FocusNode(),
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(ui.Radius.circular(12.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ColoredBox(
                    color: _gbaColor,
                    child: _LeftController(
                      onKeyPressed: widget.onKeyPressed,
                      onKeyReleased: widget.onKeyReleased,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _Screen(
                    fps: widget.fps,
                    image: widget.image,
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: _gbaColor,
                    child: _RightController(
                      onKeyPressed: widget.onKeyPressed,
                      onKeyReleased: widget.onKeyReleased,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles();
            if (result == null) return;

            var bytes = result.files.first.bytes;

            if (bytes == null) {
              final file = File(result.paths.first!);

              bytes = await file.readAsBytes();
            }

            widget.onRomSelected(bytes);
          },
          backgroundColor: _seColor,
          child: const Icon(
            Icons.file_upload,
            color: _paddingColor,
          )),
    );
  }
}

class _RightController extends StatelessWidget {
  const _RightController({
    Key? key,
    required this.onKeyPressed,
    required this.onKeyReleased,
  }) : super(key: key);

  final void Function(KeyType key) onKeyPressed;
  final void Function(KeyType key) onKeyReleased;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: 300,
        height: 400,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 40,
              width: 200,
              height: 50,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.R),
                onReleased: () => onKeyReleased(KeyType.R),
                color: _buttonColor,
                child: const Text(
                  'R',
                  style: TextStyle(
                    color: _paddingColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: 40,
              width: 80,
              height: 50,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.A),
                onReleased: () => onKeyReleased(KeyType.A),
                color: _buttonColor,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: _paddingColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 180,
              right: 150,
              width: 80,
              height: 50,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.B),
                onReleased: () => onKeyReleased(KeyType.B),
                color: _buttonColor,
                child: const Text(
                  'B',
                  style: TextStyle(
                    color: _paddingColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftController extends StatelessWidget {
  const _LeftController({
    Key? key,
    required this.onKeyPressed,
    required this.onKeyReleased,
  }) : super(key: key);

  final void Function(KeyType key) onKeyPressed;
  final void Function(KeyType key) onKeyReleased;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: 300,
        height: 400,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 40,
              width: 200,
              height: 50,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.L),
                onReleased: () => onKeyReleased(KeyType.L),
                color: _buttonColor,
                child: const Text(
                  'L',
                  style: TextStyle(
                    color: _paddingColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 30,
              width: 70,
              height: 70,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.Left),
                onReleased: () => onKeyReleased(KeyType.Left),
                color: _directionColor,
                child: const Icon(
                  Icons.arrow_left_rounded,
                  color: _paddingColor,
                  semanticLabel: 'left',
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 170,
              width: 70,
              height: 70,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.Right),
                onReleased: () => onKeyReleased(KeyType.Right),
                color: _directionColor,
                child: const Icon(
                  Icons.arrow_right_rounded,
                  color: _paddingColor,
                  semanticLabel: 'right',
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 100,
              width: 70,
              height: 70,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.Up),
                onReleased: () => onKeyReleased(KeyType.Up),
                color: _directionColor,
                child: const Icon(
                  Icons.arrow_drop_up_sharp,
                  color: _paddingColor,
                  semanticLabel: 'up',
                ),
              ),
            ),
            Positioned(
              top: 220,
              left: 100,
              width: 70,
              height: 70,
              child: _ControllerButton(
                onPressed: () => onKeyPressed(KeyType.Down),
                onReleased: () => onKeyReleased(KeyType.Down),
                color: _directionColor,
                child: const Icon(
                  Icons.arrow_drop_down_sharp,
                  color: _paddingColor,
                  semanticLabel: 'down',
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 30,
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: _ControllerButton(
                      onPressed: () => onKeyPressed(KeyType.Select),
                      onReleased: () => onKeyReleased(KeyType.Select),
                      color: _seColor,
                      child: const Text(
                        'SELECT',
                        style: TextStyle(
                          color: _paddingColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: _ControllerButton(
                      onPressed: () => onKeyPressed(KeyType.Start),
                      onReleased: () => onKeyReleased(KeyType.Start),
                      color: _seColor,
                      child: const Text(
                        'START',
                        style: TextStyle(
                          color: _paddingColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Screen extends StatefulWidget {
  const _Screen({
    Key? key,
    required this.fps,
    required this.image,
  }) : super(key: key);

  final ValueNotifier<int> fps;
  final ValueNotifier<ui.Image?> image;

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  @override
  void initState() {
    super.initState();

    widget.image.addListener(_rebuild);
  }

  @override
  void dispose() {
    super.dispose();
    widget.image.removeListener(_rebuild);
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _paddingColor,
      child: FittedBox(
        child: Card(
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: _ScreenPainter(
              image: widget.image.value,
            ),
            child: SizedBox(
              width: _width,
              height: _height,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.fps.value.toString(),
                    style: const TextStyle(
                      color: _paddingColor,
                      fontSize: 6.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControllerButton extends StatelessWidget {
  const _ControllerButton({
    Key? key,
    required this.color,
    required this.onPressed,
    required this.onReleased,
    required this.child,
  }) : super(key: key);

  final Color color;
  final void Function() onPressed;
  final void Function() onReleased;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: color,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: InkWell(
          onTapDown: (_) => onPressed(),
          onTap: () => onReleased(),
          onTapCancel: () => onReleased(),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ScreenPainter extends CustomPainter {
  const _ScreenPainter({
    required this.image,
  });

  final ui.Image? image;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()..color = _screenColor;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (image != null) {
      canvas.drawImageRect(
        image!,
        const Rect.fromLTWH(0, 0, _width, _height),
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
