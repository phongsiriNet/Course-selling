import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCoursePage extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const CreateCoursePage({super.key, required this.teacherData});

  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  final categoriesRef = FirebaseFirestore.instance.collection('categories');
  final coursesRef = FirebaseFirestore.instance.collection('courses');

  // Saving course to Firestore
  Future<void> _saveCourse() async {
    if (_courseNameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedCategory != null) {
      await coursesRef.add({
        'course_name': _courseNameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'teacher_email': widget.teacherData['email'],
        'teacher_name': widget.teacherData['username'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  // Fetching categories from Firestore
  Stream<QuerySnapshot> _getCategories() {
    return categoriesRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Course',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _courseNameController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  prefixIcon: const Icon(Icons.book, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
                      prefixIcon: const Icon(Icons.category, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.lightBlueAccent, // The new blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded edges to match the example
                    ),
                    elevation: 5, // Adds shadow to give a lifted effect
                    shadowColor: Colors.blue.shade200, // Shadow color
                  ),
                  child: const Text(
                    'Create Course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
