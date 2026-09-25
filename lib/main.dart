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
  final String baseUrl = "https://b09830eb-578e-4615-96cb-47201bc6f429.e2-us-east-8.custom.domain.com";
  String _statusMessage = "Welcome to Jarvis! Tap a button below.";
  String _lastPostId = "87226288-578e-4615-96cb-47201bc6f429";

  Future<void> _processVideo() async {
    setState(() {
      _statusMessage = "Processing video job...";
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/video/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task': 'generate_celebration_video'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _statusMessage = "Video Job Success: ${data.toString()}";
        });
      } else {
        setState(() {
          _statusMessage = "Failed: ${response.body}";
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
      _statusMessage = "Approving post $_lastPostId...";
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/social/posts/$_lastPostId/approve'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Post Approved Successfully (200 OK)!";
        });
      } else {
        setState(() {
          _statusMessage = "Approval Failed: ${response.body}";
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _processVideo,
              icon: const Icon(Icons.video_collection),
              label: const Text('Process Video Job'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _approvePost,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approve Social Post Manually'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
