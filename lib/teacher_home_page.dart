import 'package:flutter/material.dart';
import 'my_courses_page.dart'; // Import the My Courses page
import 'notifications_page.dart'; // Import the Notifications page
import 'settings_page.dart'; // Import the Settings page

class TeacherHomePage extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeacherHomePage({super.key, required this.teacherData});

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      MyCoursesPage(teacherData: widget.teacherData), // Pass teacherData
      NotificationsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // ความเร็วของแอนิเมชัน
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.school, 0),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.notifications, 1),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.settings, 2),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue.shade100,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectedIndex == index ? _animation.value : 1.0,
          child: Icon(icon),
        );
      },
    );
  }
}
