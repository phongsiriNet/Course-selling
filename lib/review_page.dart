import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final String studentId;

  const ReviewPage({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.studentId,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _commentController = TextEditingController();
  double _rating = 0.0;

  Future<void> _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    try {
      // สร้างรีวิวใหม่ใน collection 'reviews' โดยใช้ ID ของนักเรียนที่ถูกส่งมา
      await FirebaseFirestore.instance.collection('reviews').add({
        'courseId': widget.courseId,
        'lessonId': widget.lessonId,
        'studentId': widget.studentId, // ใช้ ID ที่ส่งมาโดยตรง
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );

      // เคลียร์ช่องข้อมูลและรีเซ็ตค่า
      _commentController.clear();
      setState(() {
        _rating = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Comment:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your comment here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
