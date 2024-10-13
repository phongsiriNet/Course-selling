import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_detail_page_student.dart'; // Import the LessonDetailPageStudent
import 'review_page.dart'; // Import the ReviewPage

class LessonsStudentPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  const LessonsStudentPage({super.key, required this.courseId, required this.courseName});

  @override
  Widget build(BuildContext context) {
    final lessonsRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('created_at', descending: false); // Order lessons by creation time

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lessons for $courseName',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: lessonsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = snapshot.data!.docs;

          if (lessons.isEmpty) {
            return const Center(
              child: Text(
                'No lessons available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index].data() as Map<String, dynamic>;
              final lessonId = lessons[index].id;
              final lessonTitle = lesson['title'] ?? 'No Title';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    Icons.menu_book,
                    color: Colors.blue.shade600,
                  ),
                  title: Text(
                    lessonTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.rate_review, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                            courseId: courseId,
                            lessonId: lessonId,
                            studentId: 'your-student-id', // Replace with actual student ID
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonDetailPageStudent(
                          courseId: courseId,
                          lessonId: lessonId,
                          lessonData: lesson,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
