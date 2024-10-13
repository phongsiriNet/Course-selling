import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:animate_do/animate_do.dart'; // For animations

class LessonDetailPageStudent extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final Map<String, dynamic> lessonData;

  const LessonDetailPageStudent({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.lessonData,
  });

  @override
  _LessonDetailPageStudentState createState() => _LessonDetailPageStudentState();
}

class _LessonDetailPageStudentState extends State<LessonDetailPageStudent> {
  YoutubePlayerController? _youtubePlayerController;
  bool _isYoutubeUrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.lessonData['video_url'] != null && widget.lessonData['video_url'].isNotEmpty) {
      _initializeYoutubePlayer(widget.lessonData['video_url']);
    }
  }

  void _initializeYoutubePlayer(String? url) {
    if (url != null) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        setState(() {
          _isYoutubeUrl = true;
          _youtubePlayerController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String? url) async {
    if (url != null) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _copyToClipboard(String? url, BuildContext context) {
    if (url != null) {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonData['title'] ?? 'Lesson Detail'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ZoomIn(
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
                          widget.lessonData['title'] ?? 'Lesson: N/A',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              const SizedBox(width: 10),
              const Text(
                'PDF:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(widget.lessonData['pdf_url']);
                },
                child: const Text(
                  'View PDF',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
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
          const SizedBox(width: 10),
          const Text(
            'No PDF for this lesson',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      );
    }
  }

  Widget _buildVideoSection() {
    if (_isYoutubeUrl && _youtubePlayerController != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library, color: Colors.green.shade600),
              const SizedBox(width: 10),
              const Text(
                'Video:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          YoutubePlayer(
            controller: _youtubePlayerController!,
            showVideoProgressIndicator: true,
          ),
        ],
      );
    } else if (widget.lessonData['video_url'] != null && widget.lessonData['video_url'].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library, color: Colors.green.shade600),
              const SizedBox(width: 10),
              const Text(
                'Video URL:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(widget.lessonData['video_url']);
                },
                child: Text(
                  widget.lessonData['video_url'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  _copyToClipboard(widget.lessonData['video_url'], context);
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
          const SizedBox(width: 10),
          const Text(
            'No video for this lesson',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      );
    }
  }
}
