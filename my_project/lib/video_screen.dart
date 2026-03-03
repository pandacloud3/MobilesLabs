import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SimpleVideoScreen extends StatefulWidget {
  const SimpleVideoScreen({super.key});

  @override
  State<SimpleVideoScreen> createState() => _SimpleVideoScreenState();
}

class _SimpleVideoScreenState extends State<SimpleVideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'y2AghjB4Wxs',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Відео")),
      body: Center(child: YoutubePlayer(controller: _controller)),
    );
  }
}
