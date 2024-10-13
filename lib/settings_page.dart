import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ไม่แสดงปุ่มย้อนกลับ
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            onTap: () {
              // เปิดหน้าเลือกภาษาที่นี่
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              // เปิดหน้าเปลี่ยนรหัสผ่านที่นี่
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Settings'),
            onTap: () {
              // เปิดหน้าเปลี่ยนการตั้งค่าการแจ้งเตือนที่นี่
            },
          ),
        ],
      ),
    );
  }
}
