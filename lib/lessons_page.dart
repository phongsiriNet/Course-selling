import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_detail_page.dart';

class LessonsPage extends StatelessWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const LessonsPage({super.key, required this.courseId, required this.courseData});

  // Function to add a new lesson
  Future<void> _addLesson(BuildContext context) async {
    CollectionReference lessons = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons');

    // Add a new lesson with a timestamp
    await lessons.add({
      'title': 'New Lesson Title',
      'pdf_url': '',
      'video_url': '',
      'created_at': FieldValue.serverTimestamp(), // Add a timestamp field
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lesson added'),
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to delete a lesson
  Future<void> _deleteLesson(String lessonId, BuildContext context) async {
    CollectionReference lessons = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons');

    await lessons.doc(lessonId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lesson deleted'),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to edit a lesson
  Future<void> _editLesson(String lessonId, String currentTitle, String currentPdfUrl, String currentVideoUrl, BuildContext context) async {
    TextEditingController titleController = TextEditingController(text: currentTitle);
    TextEditingController pdfUrlController = TextEditingController(text: currentPdfUrl);
    TextEditingController videoUrlController = TextEditingController(text: currentVideoUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Edit Lesson'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new lesson title',
                    prefixIcon: Icon(Icons.title, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pdfUrlController,
                  decoration: const InputDecoration(
                    hintText: 'Enter PDF URL',
                    prefixIcon: Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Video URL',
                    prefixIcon: Icon(Icons.video_library, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                CollectionReference lessons = FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .collection('lessons');

                await lessons.doc(lessonId).update({
                  'title': titleController.text,
                  'pdf_url': pdfUrlController.text,
                  'video_url': videoUrlController.text,
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Lesson updated'),
                    backgroundColor: Colors.blue.shade400,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonsRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons');

    return Scaffold(
      appBar: AppBar(
        title: Text('Lessons for ${courseData['course_name']}'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _addLesson(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: lessonsRef.orderBy('created_at', descending: false).snapshots(), // Sort lessons by timestamp
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!.docs;

          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons available'));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index].data() as Map<String, dynamic>;
              final lessonId = lessons[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    lesson['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.book, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonDetailPage(
                          lessonId: lessonId,
                          lessonData: lesson,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          _editLesson(
                              lessonId,
                              lesson['title'],
                              lesson['pdf_url'],
                              lesson['video_url'],
                              context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteLesson(lessonId, context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
