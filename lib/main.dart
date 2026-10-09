import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jarvis AI Assistant',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Yahan variable ka naam bilkul theek rakh diya gaya hai (baseURL)
  final String baseURL = "https://b09830eb-690d-4b39-9598-f2b7f75f9037.loca.lt";
  String _statusMessage = "Welcome to Jarvis! Tap a button to start.";
  String _lastPostId = "87226288-578e-4615-96cb-47206b12a32c";

  Future<void> _processVideo() async {
    setState(() {
      _statusMessage = "Processing video job...";
    });
    try {
      final response = await http.post(
        Uri.parse('$baseURL/api/video/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task': 'generate_celebration'}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Video Job Successful!";
        });
      } else {
        setState(() {
          _statusMessage = "Failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  Future<void> _approvePost() async {
    setState(() {
      _statusMessage = "Approving post...";
    });
    try {
      final response = await http.post(
        Uri.parse('$baseURL/api/social/approve/$_lastPostId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Post Approved Successfully!";
        });
      } else {
        setState(() {
          _statusMessage = "Approval Failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarvis AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _processVideo,
              child: const Text('Process Video Job'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _approvePost,
              child: const Text('Approve Last Social Post'),
            ),
          ],
        ),
      ),
    );
  }
}
