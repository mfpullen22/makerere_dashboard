import 'package:flutter/material.dart';

class EditStudentsScreen extends StatelessWidget {
  const EditStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Students Screen",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "This screen allows you to edit student information",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.blue[50], // Placeholder for additional content
              child: const Center(
                child: Text("More Content Here"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
