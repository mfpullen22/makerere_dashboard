import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        // Order by lastName in ascending order
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('lastname') // <-- This ensures alphabetical order
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading users'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final userDoc = docs[index];
              final data = userDoc.data() as Map<String, dynamic>?;

              // Extract first and last name fields
              final String firstName = data?['firstname'] ?? 'N/A';
              final String lastName = data?['lastname'] ?? 'N/A';

              return Card(
                child: ListTile(
                  title: Text('$firstName $lastName'),
                  onTap: () {
                    // Navigate to the detail screen for this user
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(userDocId: userDoc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
