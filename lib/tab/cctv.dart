import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CCTVPage extends StatefulWidget {
  final String videoUrl;

  const CCTVPage({super.key, required this.videoUrl});

  @override
  _CCTVPageState createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    print("Video URL: ${widget.videoUrl}"); // Debug URL
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Mulai pemutaran setelah inisialisasi selesai
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CCTV Live View'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
