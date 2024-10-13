import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_page.dart'; // Import the PaymentPage

class CourseListPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const CourseListPage({super.key, required this.studentData});

  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final coursesRef = FirebaseFirestore.instance.collection('courses');
  final studentsRef = FirebaseFirestore.instance.collection('students');
  String searchQuery = "";
  int studentCredit = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentCredit();
  }

  Future<void> _loadStudentCredit() async {
    try {
      String studentEmail = widget.studentData['email'];

      QuerySnapshot querySnapshot = await studentsRef
          .where('email', isEqualTo: studentEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final studentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          studentCredit = studentData['credit'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading student credit: $e');
    }
  }

  Future<String> _getCategoryName(String categoryId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance.collection('categories').doc(categoryId).get();
      if (categoryDoc.exists && categoryDoc.data() != null) {
        final data = categoryDoc.data() as Map<String, dynamic>;
        return data['category'] ?? 'Unknown Category';
      } else {
        return 'Unknown Category';
      }
    } catch (e) {
      return 'Unknown Category';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Available Courses',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false, // เอาลูกศรย้อนกลับออก
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by course, teacher, or category',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Credit:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$$studentCredit',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: coursesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs;

                final filteredCourses = courses.where((course) {
                  final courseData = course.data() as Map<String, dynamic>;
                  final courseName = (courseData['course_name'] ?? '').toString().toLowerCase();
                  final teacherName = (courseData['teacher_name'] ?? '').toString().toLowerCase();
                  final category = (courseData['category'] ?? '').toString().toLowerCase();

                  return courseName.contains(searchQuery.toLowerCase()) ||
                      teacherName.contains(searchQuery.toLowerCase()) ||
                      category.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredCourses.isEmpty) {
                  return const Center(child: Text('No courses found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final courseDoc = filteredCourses[index];
                    final courseData = courseDoc.data() as Map<String, dynamic>;
                    final courseId = courseDoc.id; // Get the Document ID of the course

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading: const Icon(Icons.school, color: Colors.blue),
                          title: Text(
                            courseData['course_name'] ?? 'No Course Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: FutureBuilder<String>(
                            future: _getCategoryName(courseData['category']),
                            builder: (context, categorySnapshot) {
                              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading category...');
                              }
                              if (categorySnapshot.hasError || !categorySnapshot.hasData) {
                                return const Text('Unknown Category');
                              }

                              return Text(
                                'Price: \$${courseData['price'] ?? 'N/A'}\nTeacher: ${courseData['teacher_name'] ?? 'Unknown'}\nCategory: ${categorySnapshot.data}',
                                style: const TextStyle(color: Colors.black54),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  courseData: courseData,
                                  studentData: widget.studentData,
                                  courseId: courseId, // Pass the Document ID of the course
                                ),
                              ),
                            );
                          },
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
