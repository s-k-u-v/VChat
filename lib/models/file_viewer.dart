import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';

class FileViewer extends StatefulWidget {
  final String fileUrl;

  const FileViewer({super.key, required this.fileUrl});

  @override
  FileViewerState createState() => FileViewerState();
}

class FileViewerState extends State<FileViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Check if the file is a video or image
    if (widget.fileUrl.endsWith('.mp4')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl))
        ..initialize().then((_) {
          setState(() {}); // Update UI when the video is initialized
        });
    }
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fileUrl.endsWith('.mp4')) {
      // Display video
      return Scaffold(
        appBar: AppBar(title: const Text('Video')),
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      );
    } else if (widget.fileUrl.endsWith('.jpg') ||
        widget.fileUrl.endsWith('.png')) {
      // Display image
      return Scaffold(
        appBar: AppBar(title: const Text('Image')),
        body: Center(
          child: PhotoView(
            imageProvider: NetworkImage(widget.fileUrl),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Unsupported File')),
        body: Center(child: const Text('This file type is not supported')),
      );
    }
  }
}
