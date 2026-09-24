import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final String baseUrl = "https://b09830eb-690d-4b39-b49c-dd51dbbb80a5-00-3rrioynzlqqmp.sisko.replit.dev/api";
  String _statusMessage = "Welcome to Jarvis! Tap a button to test.";
  String _lastPostId = "87226288-578e-4615-96cb-4baa875b6e6b";

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _processVideo() async {
    setState(() => _statusMessage = "Processing video...");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/process'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "video_url": "https://example.com/sample.mp4",
          "effect": "cinematic"
        }),
      );
      
      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        setState(() => _statusMessage = "Video Queued! Job ID: ${data['job_id']}");
      } else {
        setState(() => _statusMessage = "Failed: ${response.body}");
      }
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
    }
  }

  Future<void> _approvePost() async {
    setState(() => _statusMessage = "Approving post...");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social/posts/$_lastPostId/approve'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reviewer": "content-reviewer",
          "note": "Approved via Flutter Mobile App"
        }),
      );
      
      if (response.statusCode == 200) {
        setState(() => _statusMessage = "Success! Post status: approved 🚀");
      } else {
        setState(() => _statusMessage = "Approval Failed: ${response.body}");
      }
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
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
            const Icon(Icons.smart_toy, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _processVideo,
              icon: const Icon(Icons.video_collection),
              label: const Text('Process Video Job'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
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
      bottomNavigationBar: _isAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
