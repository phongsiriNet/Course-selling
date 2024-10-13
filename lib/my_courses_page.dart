import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lessons_page.dart'; // For displaying lessons
import 'create_course.dart'; // For creating new courses
import 'edit_course.dart'; // For editing courses

class MyCoursesPage extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const MyCoursesPage({super.key, required this.teacherData});

  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final coursesRef = FirebaseFirestore.instance.collection('courses');
  final categoriesRef = FirebaseFirestore.instance.collection('categories');

  // Function to delete course
  Future<void> _deleteCourse(String courseId) async {
    try {
      await coursesRef.doc(courseId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete course: $error')),
      );
    }
  }

  // Fetching category name from categories collection
  Future<String> _getCategoryName(String? categoryId) async {
    if (categoryId == null) {
      return 'Unknown Category';
    }
    try {
      DocumentSnapshot categoryDoc = await categoriesRef.doc(categoryId).get();
      if (categoryDoc.exists) {
        return categoryDoc['category'] ?? 'Unknown Category';
      }
    } catch (error) {
      return 'Unknown Category';
    }
    return 'Unknown Category';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateCoursePage(teacherData: widget.teacherData),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: coursesRef
              .where('teacher_email', isEqualTo: widget.teacherData['email'])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final courses = snapshot.data!.docs;

            if (courses.isEmpty) {
              return const Center(
                child: Text(
                  'No courses available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index].data() as Map<String, dynamic>;
                final courseId = courses[index].id;

                return FutureBuilder<String>(
                  future: _getCategoryName(course['category']),
                  builder: (context, categorySnapshot) {
                    String category = categorySnapshot.data ?? 'Loading...';

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the lessons page when the course is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonsPage(
                              courseId: courseId,
                              courseData: course,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          shadowColor: Colors.blue.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course['course_name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category: $category',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                                Text(
                                  'Price: \$${course['price']?.toString() ?? '0'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditCoursePage(
                                              courseId: courseId,
                                              courseData: course,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteCourse(courseId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
