import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  @override
  _WebViewAppState createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  List<String> _urls = []; // List of URLs
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _loadSavedUrls();
  }

  // Load saved URLs from SharedPreferences
  void _loadSavedUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _urls = prefs.getStringList('urls') ?? [];
    });
  }

  // Save URLs to SharedPreferences
  void _saveUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('urls', _urls);
  }

  // Open dialog to input URL
  void _addNewUrlDialog() {
    TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(hintText: "https://example.com"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty && Uri.tryParse(newUrl)?.hasAbsolutePath == true) {
                  setState(() {
                    _urls.add(newUrl);
                  });
                  _saveUrls();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Open the WebView page
  void _openWebViewPage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi WebView Browser'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewUrlDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _urls.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_urls[index]),
            onTap: () => _openWebViewPage(_urls[index]),
          );
        },
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(url)),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
