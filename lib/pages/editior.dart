import 'dart:convert' show jsonDecode;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Editor extends StatefulWidget {
  final String pathName;
  const Editor({super.key, required this.pathName});

  @override
  State<Editor> createState() => _MainFieldState(); 
}

class _MainFieldState extends State<Editor> {
  String fieldImage = 'assets/reefscapeField.png'; // default
  final List<Offset> points = [];
  final List<double?> angles = [];

  final double fieldWidthMeters = 16.54;
  final double fieldHeightMeters = 8.02;

  final double fieldScaleFactor = 0.9;

  @override
  void initState() {
    super.initState();
    _loadFieldImagePreference();
  }

  Future<void> _loadFieldImagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedField = prefs.getString('fieldType');

    setState(() {
      switch (selectedField) {
        case 'Crescendo':
          fieldImage = 'assets/crescendoField.png';
          break;
        case 'Charged Up':
          fieldImage = 'assets/chargedupField.png';
          break;
        case 'Rapid Reacts':
          fieldImage = 'assets/rapidreactsField.png';
          break;
        case 'Reefscape':
        default:
          fieldImage = 'assets/reefscapeField.png';
      }
    });
  }

  Rect _computeFieldRect(Size areaSize) {
    final aspect = fieldWidthMeters / fieldHeightMeters;
    // max size that fits
    double w = areaSize.width;
    double h = w / aspect;
    if (h > areaSize.height) {
      h = areaSize.height;
      w = h * aspect;
    }
    w *= fieldScaleFactor;
    h *= fieldScaleFactor;
    final left = (areaSize.width - w) / 2;
    final top = (areaSize.height - h) / 2;
    return Rect.fromLTWH(left, top, w, h);
  }

  void _deleteTrajectoryAndFollowing(int trajectoryIndex) {
    // trajectory i is the segment between points[i] and points[i+1]
    // Deleting trajectory i means we keep points up to i, drop points from i+1 onward
    final keepPoints = trajectoryIndex + 1;
    setState(() {
      if (keepPoints >= 0 && keepPoints <= points.length) {
        points.removeRange(keepPoints, points.length);
        angles.removeRange(keepPoints, angles.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Editor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        backgroundColor: const Color(0xFF0047B3),
      ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final rect = _computeFieldRect(constraints.biggest);

        return Row(
          children: [
            // --- Canvas (field) ---
            Expanded(
              child: Center(
                child: SizedBox(
                  width: rect.width,
                  height: rect.height,
                  child: GestureDetector(
                    onTapUp: (d) {
                      final local = d.localPosition;
                      final metersX = (local.dx / rect.width) * fieldWidthMeters;
                      final metersY = (local.dy / rect.height) * fieldHeightMeters;

                      setState(() {
                        points.add(Offset(metersX, metersY));
                        angles.add(null);
                      });
                    },
                    child: Stack(
                      children: [
                        // Field Image
                        Positioned.fill(
                          child: Image.asset(
                            fieldImage,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        // Painter
                        Positioned.fill(
                          child: CustomPaint(
                            painter: FieldPainter(
                              points: points,
                              angles: angles,
                              fieldWidthMeters: fieldWidthMeters,
                              fieldHeightMeters: fieldHeightMeters,
                              fieldRect: Rect.fromLTWH(0, 0, rect.width, rect.height), // local rect
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //Sidebar
            _buildSidebar()
          ],
        );
      },
    ),

        );
      }

  Widget _buildSidebar(){
    return Container(
      width: 280,
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Trajectories',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: points.length < 2
                ? const Center(
                    child: Text(
                      'Tap on the field to add points.\nSegments will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : ListView.separated(
                    itemCount: max(0, points.length - 1),
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, i) {
                      final p1 = points[i];
                      final p2 = points[i + 1];
                      final dx = p2.dx - p1.dx;
                      final dy = p2.dy - p1.dy;
                      final length = sqrt(dx * dx + dy * dy); // in meters
                      //add rotation

                      return ListTile(
                        dense: true,
                        title: Text(
                          'Segment $i → ${i + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Δx=${dx.toStringAsFixed(2)} m, Δy=${dy.toStringAsFixed(2)} m, '
                          'L=${length.toStringAsFixed(2)} m',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Delete this and following segments',
                          onPressed: () => _deleteTrajectoryAndFollowing(i),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    points.clear();
                    angles.clear();
                  }),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: points.isNotEmpty
                      ? () => setState(() {
                            points.removeLast();
                            angles.removeLast();
                          })
                      : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldPainter extends CustomPainter {
  final List<Offset> points;
  final List<double?> angles;
  final double fieldWidthMeters;
  final double fieldHeightMeters;
  final Rect fieldRect; 

  FieldPainter({
    required this.points,
    required this.angles,
    required this.fieldWidthMeters,
    required this.fieldHeightMeters,
    required this.fieldRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(fieldRect.left, fieldRect.top);

    final scaleX = fieldRect.width / fieldWidthMeters;
    final scaleY = fieldRect.height / fieldHeightMeters;

    final pathPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 3;

    Offset m2p(Offset m) => Offset(m.dx * scaleX, m.dy * scaleY);

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(m2p(points[i]), m2p(points[i + 1]), pathPaint);
    }

    final pointPaint = Paint()..color = const Color.fromARGB(255, 0, 255, 191);
    final anglePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2;

    for (int i = 0; i < points.length; i++) {
      final p = m2p(points[i]);
      canvas.drawCircle(p, 6, pointPaint);

      final a = angles[i];
      if (a != null) {
        final rad = a * pi / 180.0;
        final dir = Offset(cos(rad), sin(rad));
        final end = p + dir * 30;
        canvas.drawLine(p, end, anglePaint);

        final label = TextPainter(
          text: TextSpan(text: '${a.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 12)),
          textDirection: TextDirection.ltr,
        );
        label.layout();
        label.paint(canvas, p + const Offset(8, -20));
      }
    }
    canvas.restore();
  }

  //Exporting and importing path data
  Future<bool> pathExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  Future<Map<String, dynamic>> decodeData(String jsonFile) async {
    final Map<String, dynamic> data = jsonDecode(jsonFile);
    return data;
  }

  Future<void> loadData(String path) async {
    String filePath = 'assets/paths/$path.json';
    String defaultPath = 'assets/paths/example.json';
    if(await pathExists(filePath)){
      decodeData(filePath);
      
    }
    else{
      decodeData(defaultPath);
      
    }
  }

  @override
  bool shouldRepaint(FieldPainter old) =>
      old.points != points || old.angles != angles || old.fieldRect != fieldRect;
}