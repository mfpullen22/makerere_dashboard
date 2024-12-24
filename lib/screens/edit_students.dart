import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makerere_dashboard/screens/edit_student_details.dart';

class EditStudentsScreen extends StatefulWidget {
  const EditStudentsScreen({super.key});

  @override
  State<EditStudentsScreen> createState() => _EditStudentsScreenState();
}

class _EditStudentsScreenState extends State<EditStudentsScreen> {
  String? selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Students"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Students",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tap a student to edit their details.",
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildClassButton("MMed1", "mmed1"),
                  _buildClassButton("MMed2", "mmed2"),
                  _buildClassButton("MMed3", "mmed3"),
                ],
              ),
              const SizedBox(height: 16),
              if (selectedClass == null)
                const Text(
                  "Please select a class of students above.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                )
              else
                _buildStudentsList(selectedClass!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassButton(String buttonText, String classValue) {
    final isSelected = selectedClass == classValue;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedClass = classValue;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[900] : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(buttonText),
    );
  }

  Widget _buildStudentsList(String classFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('class', isEqualTo: classFilter)
          .orderBy('lastname')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            "No students found.",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          );
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final fullName = "${student['firstname']} ${student['lastname']}";

            return ListTile(
              title: Text(fullName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditStudentDetailsScreen(
                      documentId:
                          student.id, // student.id is the Firestore doc ID
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
