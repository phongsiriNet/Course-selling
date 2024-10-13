import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ไม่แสดงปุ่มย้อนกลับ
        title: const Text('Notifications'),
      ),
      body: Center(
        child: const Text('Notifications Page'),
      ),
    );
  }
}
