import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lessons_student_page.dart'; // Import the lessons student page

class MyCoursesStudentPage extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const MyCoursesStudentPage({super.key, required this.studentData});

  // Function to fetch the course data based on the courseId
  Future<Map<String, dynamic>?> _getCourseData(String courseId) async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
      if (courseDoc.exists && courseDoc.data() != null) {
        return courseDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching course data: $e');
    }
    // Return null if no valid course data is found
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final paymentsRef = FirebaseFirestore.instance.collection('payments');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide the back arrow
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentsRef.where('studentId', isEqualTo: studentData['id']).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final purchases = snapshot.data!.docs;

          if (purchases.isEmpty) {
            return const Center(
              child: Text(
                'No courses found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final paymentData = purchases[index].data() as Map<String, dynamic>;
              final courseId = paymentData['courseId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getCourseData(courseId),
                builder: (context, courseDataSnapshot) {
                  if (courseDataSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading course details...'),
                      leading: CircularProgressIndicator(),
                    );
                  }

                  if (courseDataSnapshot.hasError || !courseDataSnapshot.hasData || courseDataSnapshot.data == null) {
                    return const SizedBox.shrink(); // Return an empty widget
                  }

                  final courseData = courseDataSnapshot.data!;
                  final courseName = courseData['course_name'] ?? 'No Course Name';
                  final courseDescription = courseData['description'] ?? '-';
                  final teacherName = courseData['teacher_name'] ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(
                        Icons.book,
                        color: Colors.blue.shade600,
                      ),
                      title: Text(
                        courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Description: $courseDescription\n'
                        'Teacher: $teacherName',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonsStudentPage(
                              courseId: courseId,
                              courseName: courseName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
