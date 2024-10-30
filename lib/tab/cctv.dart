// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class CCTVPage extends StatefulWidget {
//   final String videoUrl;

//   const CCTVPage({super.key, required this.videoUrl});

//   @override
//   _CCTVPageState createState() => _CCTVPageState();
// }

// class _CCTVPageState extends State<CCTVPage> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     print("Video URL: ${widget.videoUrl}"); // Debug URL

//     // Menggunakan VideoPlayerController.network
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play(); // Mulai pemutaran setelah inisialisasi selesai
//       }).catchError((error) {
//         print("Error initializing video player: $error"); // Menangani kesalahan
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CCTV Live View'),
//       ),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class CCTVPage extends StatelessWidget {
//   final String videoUrl;

//   const CCTVPage({super.key, required this.videoUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CCTV Live View'),
//       ),
//       body: WebView(
//         initialUrl: videoUrl,
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class CCTVPage extends StatelessWidget {
//   final String videoUrl;

//   const CCTVPage({super.key, required this.videoUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CCTV Live View'),
//       ),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse(videoUrl)),
//         initialOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(
  
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class CCTVPage extends StatefulWidget {
//   final String videoUrl;

//   const CCTVPage({super.key, required this.videoUrl});

//   @override
//   _CCTVPageState createState() => _CCTVPageState();
// }

// class _CCTVPageState extends State<CCTVPage> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // Ambil ID video dari URL
//     String videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
//     _controller = YoutubePlayerController(
//       initialVideoId: videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CCTV Live View'),
//       ),
//       body: Center(
//         child: YoutubePlayer(
//           controller: _controller,
//           showVideoProgressIndicator: true,
//         ),
//       ),
//     );
//   }
// }

import 'dart:io'; // Pastikan untuk mengimpor paket ini
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CCTVPage extends StatefulWidget {
  final String videoUrl; // Menggunakan path video lokal

  const CCTVPage({super.key, required this.videoUrl});

  @override
  _CCTVPageState createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    print("Video Path: ${widget.videoUrl}"); // Debug path
    _controller = VideoPlayerController.asset(widget.videoUrl)
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
