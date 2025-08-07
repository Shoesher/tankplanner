import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tankplanner/pages/editior.dart';
import 'package:tankplanner/pages/settings.dart';

class PathItem {
  String name;
  PathItem({required this.name});
}

class FolderItem {
  String name;
  List<PathItem> children;
  FolderItem({required this.name, this.children = const []});
}

class Preview extends StatefulWidget {
  const Preview({super.key});
  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  bool _showSidebar = false;
  final List<PathItem> _paths = [];
  final List<FolderItem> _folders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
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
          if (_showSidebar)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSidebar = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
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
                        _folders.add(FolderItem(name: 'Folder ${_folders.length + 1}', children: []));
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
                        _paths.add(PathItem(name: 'Path ${_paths.length + 1}'));
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
              children: [
                for (final folder in _folders) _buildFolderWidget(folder),
                for (final path in _paths) _buildPathWidget(path),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathWidget(PathItem path) {
    return Draggable<PathItem>(
      data: path,
      feedback: _buildBox(Icons.route, Colors.grey.shade700),
      childWhenDragging: _buildBox(Icons.route, Colors.grey.shade800),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const Editor()));
        },
        child: Stack(
            children: [
              _buildBox(Icons.route, const Color(0xFF3C3C3C)),
              Text(path.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
              Positioned(
                right: 4,
                top: 4,
                child: PopupMenuButton(
                  color: Colors.black,
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Rename', style: TextStyle(color: Colors.white)),
                      onTap: () => _renamePath(path),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      onTap: () => _deletePath(path),
                    ),
                  ],
                ),
              ),
            ],
          ),
      )
    );
  }

  Widget _buildFolderWidget(FolderItem folder) {
    return DragTarget<PathItem>(
      onAccept: (path) {
        setState(() {
          _paths.remove(path);
          folder.children = [...folder.children, path];
        });
      },
      builder: (context, candidateData, rejectedData) => Stack(
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3C3C3C),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(folder.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 10),
                ...folder.children.map((path) => Text(path.name, style: const TextStyle(color: Colors.grey)))
              ],
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: PopupMenuButton(
              color: Colors.black,
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Rename', style: TextStyle(color: Colors.white)),
                  onTap: () => _renameFolder(folder),
                ),
                PopupMenuItem(
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  onTap: () => _deleteFolder(folder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(IconData icon, Color color) {
    return Container(
      width: 200.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Icon(icon, color: Colors.white, size: 40),
    );
  }

  void _renameFolder(FolderItem folder) async {
    final controller = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          )
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      setState(() {
        folder.name = name.trim();
      });
    }
  }

  void _deleteFolder(FolderItem folder) {
    setState(() {
      _folders.remove(folder);
    });
  }

  void _renamePath(PathItem path) async {
    final controller = TextEditingController(text: path.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Path'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          )
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      setState(() {
        path.name = name.trim();
      });
    }
  }

  void _deletePath(PathItem path) {
    setState(() {
      _paths.remove(path);
    });
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text('Exit', style: TextStyle(color: Colors.white)),
            onTap: () => exit(0),
          ),
        ],
      ),
    );
  }
}