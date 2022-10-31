import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('제목'),
          actions: [
            IconButton(
              onPressed: () {
                _controller.goBack();
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            IconButton(
              onPressed: () {
                _controller.goForward();
              },
              icon: const Icon(Icons.arrow_forward_outlined),
            ),
            IconButton(
              onPressed: () {
                _controller.loadUrl('https://google.com');
              },
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                _controller.runJavascript('alert("hello");');
              },
              icon: const Icon(Icons.play_arrow),
            ),
            IconButton(
              onPressed: () {
                _loadHtmlFromAssets();
              },
              icon: const Icon(Icons.play_arrow),
            ),
          ],
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://flutter.dev',
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          javascriptChannels: {
            JavascriptChannel(
              name: 'myChannel',
              onMessageReceived: (JavascriptMessage message) {
                log(message.message);

                Map<String, dynamic> json = jsonDecode(message.message);

                log(json['title']);
                log(json['body']);
              },
            ),
          },
        ),
      ),
    );
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/index.html');
    _controller.loadUrl(
      Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString(),
    );
  }
}
