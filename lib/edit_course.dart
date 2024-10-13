import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCoursePage extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> courseData;

  const EditCoursePage({super.key, required this.courseId, required this.courseData});

  @override
  _EditCoursePageState createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  late TextEditingController _courseNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedCategory;

  final categoriesRef = FirebaseFirestore.instance.collection('categories');
  final coursesRef = FirebaseFirestore.instance.collection('courses');

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.courseData['course_name']);
    _descriptionController = TextEditingController(text: widget.courseData['description']);
    _priceController = TextEditingController(text: widget.courseData['price'].toString());
    _selectedCategory = widget.courseData['category'];
  }

  // Saving changes to Firestore
  Future<void> _updateCourse() async {
    await coursesRef.doc(widget.courseId).update({
      'course_name': _courseNameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'category': _selectedCategory,
      'teacher_email': widget.courseData['teacher_email'],
    });

    Navigator.pop(context);
  }

  // Fetching categories from Firestore
  Stream<QuerySnapshot> _getCategories() {
    return categoriesRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Name Field with Animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: TextField(
                  controller: _courseNameController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.book, color: Colors.blue),
                    labelStyle: const TextStyle(color: Colors.blue),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Description Field
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description, color: Colors.lightBlue),
                  labelStyle: const TextStyle(color: Colors.lightBlue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.lightBlue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Price Field
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.blueAccent),
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Dropdown Menu for Categories with Styling
              StreamBuilder<QuerySnapshot>(
                stream: _getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: categories.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(data['category']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category, color: Colors.blueGrey),
                      labelStyle: const TextStyle(color: Colors.blueGrey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    dropdownColor: Colors.blue[50],
                  );
                },
              ),
              const SizedBox(height: 30),
              // Animated and Styled Button
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue, // Button color
                      foregroundColor: Colors.white, // Text color
                      shadowColor: Colors.lightBlue.withOpacity(0.5),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _updateCourse,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      child: Text(
                        'Update Course',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
