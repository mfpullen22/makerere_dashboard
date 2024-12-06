import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentsScreen extends StatelessWidget {
  const EditStudentsScreen({super.key});

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
              _buildStudentsSection("MMed1", "mmed1"),
              const SizedBox(height: 16),
              _buildStudentsSection("MMed2", "mmed2"),
              const SizedBox(height: 16),
              _buildStudentsSection("MMed3", "mmed3"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsSection(String title, String classFilter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
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
              return const Text("No students found.");
            }

            final students = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final fullName =
                    "${student['firstname']} ${student['lastname']}";

                return ListTile(
                  title: Text(fullName),
                  onTap: () {
                    // For now, this doesn't navigate anywhere.
                    print("Tapped on $fullName");
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
