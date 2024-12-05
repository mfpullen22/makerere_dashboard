import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makerere_dashboard/screens/add_presentation.dart';
import 'package:makerere_dashboard/screens/edit_schedule.dart';
import 'package:makerere_dashboard/screens/edit_students.dart';
import 'package:makerere_dashboard/screens/home.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  Widget _activePage = const HomeScreen();
  String _activePageTitle = "Home";

  void _selectPage(Widget page, String title) {
    setState(() {
      _activePage = page;
      _activePageTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(_activePageTitle),
        actions: [
          IconButton(
            onPressed: () => _selectPage(const HomeScreen(), "Home"),
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: _buildSidebar(),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: screenWidth * 0.2,
              child: _buildSidebar(),
            ),
          if (isDesktop) const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            child: _activePage,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        ListTile(
          title: const Text("Home"),
          selected: _activePageTitle == "Home",
          onTap: () {
            _selectPage(const HomeScreen(), "Home");
            if (MediaQuery.of(context).size.width <= 800) {
              Navigator.of(context).pop(); // Close drawer if on mobile
            }
          },
        ),
        ListTile(
          title: const Text("Add Presentation"),
          selected: _activePageTitle == "Add Presentation",
          onTap: () {
            _selectPage(AddPresentationScreen(), "Add Presentation");
            if (MediaQuery.of(context).size.width <= 800) {
              Navigator.of(context).pop(); // Close drawer if on mobile
            }
          },
        ),
        ListTile(
          title: const Text("Edit Schedule"),
          selected: _activePageTitle == "Edit Schedule",
          onTap: () {
            _selectPage(const EditScheduleScreen(), "Edit Schedule");
            if (MediaQuery.of(context).size.width <= 800) {
              Navigator.of(context).pop(); // Close drawer if on mobile
            }
          },
        ),
        ListTile(
          title: const Text("Edit Students"),
          selected: _activePageTitle == "Edit Students",
          onTap: () {
            _selectPage(const EditStudentsScreen(), "Edit Students");
            if (MediaQuery.of(context).size.width <= 800) {
              Navigator.of(context).pop(); // Close drawer if on mobile
            }
          },
        ),
      ],
    );
  }
}
