import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JsMessageHandler = void Function(Map<String, dynamic> message);

// NEW props + helpers
class CubeWebView extends StatefulWidget {
  final int? initialSize;                 // ⬅ pass level.size here
  final JsMessageHandler? onJsMessage;
  const CubeWebView({super.key, this.initialSize, this.onJsMessage});

  @override
  CubeWebViewState createState() => CubeWebViewState();
}

class CubeWebViewState extends State<CubeWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Flutter', onMessageReceived: _onJsMessage)
      ..setBackgroundColor(const Color(0xFF0B0B10))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) async {
          if (widget.initialSize != null) {
            await _controller.runJavaScript('window.createCube(${widget.initialSize});');
          }
        },
      ))
      ..loadFlutterAsset('assets/web/cube.html');
  }

  // Existing helpers…
  Future<void> scramble([int moves = 12]) async {
    await _controller.runJavaScript('if(window.scramble) window.scramble($moves);');
  }

  Future<void> resetCube() async {
    await _controller.runJavaScript('if(window.resetCube) window.resetCube();');
  }

  // NEW: build N×N on demand
  Future<void> createCube(int n) async {
    await _controller.runJavaScript('if(window.createCube) window.createCube($n);');
  }

  // NEW: single turn like 'U', "R'", etc.
  Future<void> turn(String move) async {
    final m = move.replaceAll("'", "\\'");
    await _controller.runJavaScript("if(window.turn) window.turn('$m');");
  }

  // NEW: run a full algorithm string e.g. "R U R' U'"
  Future<void> runAlg(String alg) async {
    final a = alg.replaceAll("'", "\\'");
    await _controller.runJavaScript("if(window.runAlg) window.runAlg('$a');");
  }

  void _onJsMessage(JavaScriptMessage message) {
    final data = message.message;
    debugPrint('📩 Message from JS: $data');

    // If you want to send it back to Flutter logic
    if (widget.onJsMessage != null) {
      widget.onJsMessage!(data as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
