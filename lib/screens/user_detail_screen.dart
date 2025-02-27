// lib/screens/user_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final String userDocId;

  const UserDetailScreen({super.key, required this.userDocId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading user details'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If doc doesn't exist, we can show some fallback
          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('User document not found'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List<dynamic> meetings = userData['meetings'] ?? [];
          final List<dynamic> reviews = userData['reviews'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- COLUMN 1: MENTORSHIP MEETINGS ----------
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mentorship Meetings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: meetings.isEmpty
                            ? const Center(
                                child: Text('No Mentorship Meetings Recorded'),
                              )
                            : ListView.builder(
                                itemCount: meetings.length,
                                itemBuilder: (context, index) {
                                  final meeting = meetings[index]
                                          as Map<String, dynamic>? ??
                                      {};
                                  final metWith = meeting['metWith'] ?? 'N/A';
                                  final date = meeting['date'] ?? 'N/A';
                                  final notes = meeting['notes'] ?? 'N/A';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Met With: $metWith',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Date: $date'),
                                          const SizedBox(height: 8),
                                          Text('Notes: $notes'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ---------- COLUMN 2: STUDENT REVIEWS ----------
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: reviews.isEmpty
                            ? const Center(
                                child: Text('No Reviews'),
                              )
                            : ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review =
                                      reviews[index] as Map<String, dynamic>? ??
                                          {};
                                  final reviewer = review['reviewer'] ?? 'N/A';
                                  final timestamp =
                                      review['timestamp'] ?? 'N/A';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text('Reviewer: $reviewer'),
                                      subtitle: Text('Date: $timestamp'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
