import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tankplanner/pages/settings.dart';

class Preview extends StatefulWidget {
  const Preview({super.key});
  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  bool _showSidebar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color(0xFF121212),
    body: Stack(
      children: [
        // Main content
        Column(
          children: [
            AppBar(
              title: const Text(
                'Tankplanner',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 0, 71, 179),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 40),
                  onPressed: () {
                    setState(() {
                      _showSidebar = !_showSidebar;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDashboard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Tap-to-close overlay
        if (_showSidebar)
          GestureDetector(
            onTap: () {
              setState(() {
                _showSidebar = false;
              });
            },
            child: Container(
              color: Colors.black.withOpacity(0.5), // semi-transparent overlay
            ),
          ),

        // Sidebar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: 0,
          bottom: 0,
          right: _showSidebar ? 0 : -250,
          child: _buildSideBar(context),
        ),
      ],
    ),
  );
  }
}

Widget _buildSideBar(BuildContext context) {
  return Container(
    width: 250,
    color: const Color(0xFF1E1E1E),
    child: Column(
      children: [
        const DrawerHeader(
          child: Text(
            'Options',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.white),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: Colors.white),
          title: const Text('Documentation', style: TextStyle(color: Colors.white)),
          onTap: () {
            // Add navigator to documentation page
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.white),
          title: const Text('Exit', style: TextStyle(color: Colors.white)),
          onTap: () {
            exit(0);
          },
        ),
      ],
    ),
  );
}

Widget _buildDashboard() {
  return Card(
    color: const Color(0xFF2C2C2C),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SearchBar(
            backgroundColor: WidgetStatePropertyAll(Color(0xFF3C3C3C)),
            textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
            hintText: 'Search for a path',
            hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.grey)),
            leading: const Icon(Icons.search, color: Colors.white),
            elevation: const WidgetStatePropertyAll(0),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined, color: Colors.white, size: 50),
            onPressed: () {
              // Add a new widget of a folder
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outlined, color: Colors.white, size: 50),
            onPressed: () {
              // Add a new widget of a path file
            },
          ),
        ],
      ),
    ),
  );
}