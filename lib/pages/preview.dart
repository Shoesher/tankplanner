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
  final List<Widget> _items = [];
  int pathOrder = 0;
  int folderOrder = 0;

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

    Widget _buildDashboard() {
    return Card(
      color: const Color(0xFF2C2C2C),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    backgroundColor: const WidgetStatePropertyAll(Color(0xFF3C3C3C)),
                    textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
                    hintText: 'Search for a path',
                    hintStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.grey)),
                    leading: const Icon(Icons.search, color: Colors.white),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ),
                
                Tooltip(
                  message: 'Add folder',
                  child: IconButton(
                    icon: const Icon(Icons.folder_open_outlined, color: Colors.white, size: 40),
                    onPressed: () {
                      setState(() {
                        _items.add(_buildDraggable(false));
                      });
                    },
                  ),
                ),

                Tooltip(
                  message: 'Add path',
                  child: IconButton(
                  icon: const Icon(Icons.add_circle_outlined, color: Colors.white, size: 40),
                    onPressed: () {
                      setState(() {
                        _items.add(_buildDraggable(true));
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _items,
            ),
          ],
        ),
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
          title: const Text('Docs', style: TextStyle(color: Colors.white)),
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


Widget _buildDraggable(bool isPath) {
  int idle = 0;
  int drag = 1;
  int og = 2;
  if(isPath){
    return Draggable(
      feedback: _buildPath(drag),
      childWhenDragging: _buildPath(og),
      child: _buildPath(idle),
    );
  }
  else{
    return Draggable(
      feedback: _buildFolder(drag),
      childWhenDragging: _buildFolder(og),
      child: _buildFolder(idle),
    );
  }
}

Widget _buildPath(int state) {
  switch(state){
    case 0: //Idle path 
      return Container(
        width: 200.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C), 
        borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Icon(
          Icons.route, color: Colors.white, size: 40
        ),
      );
    case 1: //Dragged path
      return Container(
        width: 200.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color.fromARGB(255, 60, 60, 60), 
        borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Icon(
          Icons.route, color: Colors.white, size: 40
        ),
      );
    case 2: //Path starting location
      return Container(
        width: 200.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color.fromARGB(255, 151, 182, 207), 
        borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Icon(
          Icons.route, color: Color.fromARGB(255, 37, 37, 37), size: 40
        ),
      );
    default:
      return const SizedBox(); //This will never be active lol
  }
}

Widget _buildFolder(int state) {
  switch(state){
    case 0: //Idle path 
      return Container(
        width: 590.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C), 
        borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Icon(
          Icons.folder, color: Colors.white, size: 40
        ),
      );
    case 1: //Dragged path
      return Container(
        width: 590.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 135, 33), 
        borderRadius: BorderRadius.circular(20.0),
        ),
      );
    case 2: //Path starting location
      return Container(
        width: 590.0, 
        height: 150.0, 
        decoration: BoxDecoration(
        color: const Color.fromARGB(255, 174, 0, 255), 
        borderRadius: BorderRadius.circular(20.0),
        ),
      );
    default:
      return const SizedBox(); //This will never be active lol
  }
}