import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart'; // ใช้แพ็กเกจ Animate_do สำหรับ Animation

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final Map<String, dynamic> studentData;
  final String courseId;

  const PaymentPage({
    super.key,
    required this.courseData,
    required this.studentData,
    required this.courseId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final paymentsRef = FirebaseFirestore.instance.collection('payments');
  int studentCredit = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentCredit();
  }

  Future<void> _loadStudentCredit() async {
    try {
      String studentEmail = widget.studentData['email'];

      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: studentEmail)
          .limit(1)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        final studentData = studentSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          studentCredit = studentData['credit'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading student credit: $e');
    }
  }

  Future<void> _savePurchase() async {
    try {
      String courseId = widget.courseId;
      String studentEmail = widget.studentData['email'];

      // Cast the price safely to an integer
      int coursePrice = (widget.courseData['price'] as num).toInt();

      if (studentCredit < coursePrice) {
        throw Exception('เครดิตของคุณไม่เพียงพอ');
      }

      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: studentEmail)
          .limit(1)
          .get();

      if (studentSnapshot.docs.isEmpty) {
        throw Exception('ไม่พบนักเรียนในระบบ');
      }

      DocumentSnapshot studentDoc = studentSnapshot.docs.first;
      String studentId = studentDoc.id;

      Map<String, dynamic> purchaseData = {
        'studentId': studentId,
        'courseId': courseId,
        'price': coursePrice,
        'purchaseDate': Timestamp.now(),
      };

      await paymentsRef.add(purchaseData);

      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
        'credit': studentCredit - coursePrice,
      });

      setState(() {
        studentCredit -= coursePrice;
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'การซื้อสำเร็จ!',
            textAlign: TextAlign.center,
          ),
          content: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 80,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'เกิดข้อผิดพลาด',
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase ${widget.courseData['course_name']}'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeIn(
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.book, color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Course: ${widget.courseData['course_name']}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Description: ${widget.courseData['description'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Teacher: ${widget.courseData['teacher_name'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Price: \$${widget.courseData['price']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Your Credit: \$${studentCredit}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _savePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Purchase',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
