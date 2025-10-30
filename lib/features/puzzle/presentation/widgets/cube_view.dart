import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef JsMessageHandler = void Function(Map<String, dynamic> message);

class CubeWebView extends StatefulWidget {
  final JsMessageHandler? onJsMessage;
  const CubeWebView({super.key, this.onJsMessage});

  @override
  CubeWebViewState createState() => CubeWebViewState();
}

// NOTE: This State class is PUBLIC (no leading underscore). That allows other
// files to write: GlobalKey<CubeWebViewState>() and call methods like scramble().
class CubeWebViewState extends State<CubeWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Flutter', onMessageReceived: _onJsMessage)
      ..setBackgroundColor(const Color(0xFF0B0B10));

    // load the local asset (assets/web/cube.html)
    _controller.loadFlutterAsset('assets/web/cube.html');
  }

  void _onJsMessage(JavaScriptMessage msg) {
    try {
      final Map<String, dynamic> data = jsonDecode(msg.message);
      if (widget.onJsMessage != null) widget.onJsMessage!(data);
    } catch (e) {
      // ignore parse errors
    }
  }

  // Public helpers for the parent widget to call
  Future<void> scramble([int moves = 12]) async {
    await _controller.runJavaScript('if(window.scramble) window.scramble($moves);');
  }

  Future<void> resetCube() async {
    await _controller.runJavaScript('if(window.resetCube) window.resetCube();');
  }

  Future<void> setStickerColor(String face, int cx, int cy, String hexColor) async {
    final safe = hexColor.startsWith('#') ? hexColor : '#$hexColor';
    await _controller.runJavaScript("if(window.setStickerColor) window.setStickerColor('$face',$cx,$cy,'$safe');");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}