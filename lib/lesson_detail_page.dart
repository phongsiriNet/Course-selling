import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart'; // Ensure you have animate_do package added in your pubspec.yaml

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final Map<String, dynamic> lessonData;

  const LessonDetailPage({super.key, required this.lessonId, required this.lessonData});

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  YoutubePlayerController? _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.lessonData['video_url'] != null && widget.lessonData['video_url'].isNotEmpty) {
      _initializeYoutubePlayer(widget.lessonData['video_url']);
    }
  }

  void _initializeYoutubePlayer(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      setState(() {});
    } else {
      print('Invalid YouTube URL');
    }
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _copyToClipboard(String url, BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonData['title'] ?? 'Lesson Detail'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZoomIn( // Animation for the card
            duration: const Duration(milliseconds: 500),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.blue.shade600, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          widget.lessonData['title'] ?? 'Lesson Detail',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // PDF Section
                    FadeInLeft(
                      duration: const Duration(milliseconds: 300),
                      child: _buildPDFSection(),
                    ),
                    const SizedBox(height: 20),
                    // Video Section
                    FadeInRight(
                      duration: const Duration(milliseconds: 300),
                      child: _buildVideoSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPDFSection() {
    if (widget.lessonData['pdf_url'] != null && widget.lessonData['pdf_url'].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'PDF:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(widget.lessonData['pdf_url']);
                },
                child: Text(
                  'View PDF',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () {
                  _copyToClipboard(widget.lessonData['pdf_url'], context);
                },
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 8),
          const Text(
            'ไม่มี PDF สำหรับบทเรียนนี้',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      );
    }
  }

  Widget _buildVideoSection() {
    if (widget.lessonData['video_url'] != null && widget.lessonData['video_url'].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'Video:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(widget.lessonData['video_url']);
                },
                child: Text(
                  'Copy Link',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () {
                  _copyToClipboard(widget.lessonData['video_url'], context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_youtubePlayerController != null)
            YoutubePlayer(
              controller: _youtubePlayerController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            )
          else
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Error loading video. Please check the URL.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 8),
          const Text(
            'ไม่มี Video สำหรับบทเรียนนี้',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      );
    }
  }
}
