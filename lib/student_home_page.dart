import 'package:flutter/material.dart';
import 'course_list_page.dart'; // Import CourseListPage
import 'my_courses_student_page.dart'; // Import My Courses Page for Student
import 'notifications_page.dart';
import 'settings_page.dart';

class StudentHomePage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentHomePage({super.key, required this.studentData});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _selectedIndex = 0;

  // Function to switch between tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget options for each tab
    List<Widget> _widgetOptions = <Widget>[
      CourseListPage(studentData: widget.studentData), // Display courses
      MyCoursesStudentPage(studentData: widget.studentData), // Use MyCourses for Students
      NotificationsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex), // Display selected tab content with animation
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex, // Currently selected tab
        selectedItemColor: Colors.blue.shade800, // Active tab color
        unselectedItemColor: Colors.grey, // Inactive tab color
        backgroundColor: Colors.blue.shade50, // Background color of the bottom bar
        onTap: _onItemTapped, // Switch tabs
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}
