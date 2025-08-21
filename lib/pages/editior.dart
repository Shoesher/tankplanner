// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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
  late final File filePath;

  @override
  void initState() {
    super.initState();
    _loadFieldImagePreference();
    loadData(widget.pathName);
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
    final keepPoints = trajectoryIndex + 1;
    setState(() {
      if (keepPoints >= 0 && keepPoints <= points.length) {
        points.removeRange(keepPoints, points.length);
        angles.removeRange(keepPoints, angles.length);
      }
    });
  }

  /// Compute field-relative angle in degrees from point A to point B
  double computeAngleDegrees(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final radians = atan2(dy, dx);
    final degrees = radians * 180 / pi;
    return (degrees + 360) % 360; // normalize 0–360
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(144, 0, 0, 0),
            title: const Text(
              'Save changes?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Do you want to save your changes before leaving the editor?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  saveData();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Save & Exit'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(
            'Editor',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
          ),
          backgroundColor: const Color(0xFF0047B3),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final rect = _computeFieldRect(constraints.biggest);

            return Row(
              children: [
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
                        final newPoint = Offset(metersX, metersY);

                        setState(() {
                          points.add(newPoint);

                          if (points.length > 1) {
                            // compute angle of the new segment
                            final angle = computeAngleDegrees(points[points.length - 2], newPoint);
                            // update the previous point’s angle
                            angles[points.length - 2] = angle;
                            // assign the same angle to the new point
                            angles.add(angle);
                          } else {
                            // first point, no segment yet
                            angles.add(0);
                          }
                        });
                      },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                fieldImage,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: FieldPainter(
                                  points: points,
                                  angles: angles,
                                  fieldWidthMeters: fieldWidthMeters,
                                  fieldHeightMeters: fieldHeightMeters,
                                  fieldRect: Rect.fromLTWH(
                                      0, 0, rect.width, rect.height),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildSidebar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<File> _getJsonFile([String? specPath]) async {
    final baseDir = await getApplicationSupportDirectory();
    final appFolder = Directory('${baseDir.path}/TankPlannerPaths');
    if (!await appFolder.exists()) {
      await appFolder.create(recursive: true);
    }
    final fileName = (specPath != null) ? '$specPath.json' : '${widget.pathName}.json';
    return File('${appFolder.path}/$fileName');
  }

  Future<void> loadData(String path) async {
    filePath = await _getJsonFile();
    String defaultPath = 'assets/paths/example.json';
    String jsonString;

    try {
      jsonString = await filePath.readAsString();
    } catch (e) {
      debugPrint('Loading default path.');
      try {
        jsonString = await File(defaultPath).readAsString();
      } catch (e) {
        debugPrint('Default path not found. Cannot load any data.');
        return;
      }
    }

    final Map<String, dynamic> data = jsonDecode(jsonString);
    points.clear();
    angles.clear();

    if (data.containsKey('trajectories') && data['trajectories'] is List) {
      final List trajectories = data['trajectories'];
      for (var traj in trajectories) {
        final start = traj['startPoint'];
        final end = traj['endPoint'];

        if (start != null && end != null) {
          if (points.isEmpty ||
              points.last.dx != start['x'] ||
              points.last.dy != start['y']) {
            final startPoint = Offset(
              (start['x'] as num).toDouble(),
              (start['y'] as num).toDouble(),
            );
            points.add(startPoint);

            if (start['rot'] != null) {
              angles.add((start['rot'] as num).toDouble());
            } else {
              angles.add(0); // no prior angle, set default
            }
          }

          final endPoint = Offset(
            (end['x'] as num).toDouble(),
            (end['y'] as num).toDouble(),
          );
          points.add(endPoint);

          if (end['rot'] != null) {
            angles.add((end['rot'] as num).toDouble());
          } else {
            final angle =
                computeAngleDegrees(points[points.length - 2], endPoint);
            angles.add(angle);
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> saveData() async {
    try {
      final List<Map<String, dynamic>> trajectoryList = [];
      for (int i = 0; i < points.length - 1; i++) {
        trajectoryList.add({
          'startPoint': {
            'x': points[i].dx,
            'y': points[i].dy,
            'rot': angles[i] ?? 0,
          },
          'endPoint': {
            'x': points[i + 1].dx,
            'y': points[i + 1].dy,
            'rot': angles[i + 1] ?? 0,
          },
        });
      }

      final Map<String, dynamic> data = {
        'trajectories': trajectoryList,
      };

      final jsonString = jsonEncode(data);
      await filePath.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Path saved to ${filePath.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save path: $e')),
      );
    }
  }

  Widget _buildSidebar() {
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
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
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, i) {
                      final p1 = points[i];
                      final p2 = points[i + 1];
                      final dx = p2.dx - p1.dx;
                      final dy = p2.dy - p1.dy;
                      final length = sqrt(dx * dx + dy * dy);

                      return ListTile(
                        dense: true,
                        title: Text(
                          'Segment $i → ${i + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Δx=${dx.toStringAsFixed(2)} m, Δy=${dy.toStringAsFixed(2)} m, '
                          'L=${length.toStringAsFixed(2)} m, '
                          'θ=${angles[i + 1]?.toStringAsFixed(1) ?? "?"}°',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          tooltip:
                              'Delete this and following segments',
                          onPressed: () =>
                              _deleteTrajectoryAndFollowing(i),
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

    final pointPaint =
        Paint()..color = const Color.fromARGB(255, 0, 255, 191);
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
          text: TextSpan(
              text: '${a.toStringAsFixed(0)}°',
              style:
                  const TextStyle(color: Colors.white, fontSize: 12)),
          textDirection: TextDirection.ltr,
        );
        label.layout();
        label.paint(canvas, p + const Offset(8, -20));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(FieldPainter old) =>
      old.points != points ||
      old.angles != angles ||
      old.fieldRect != fieldRect;
}

class FileManager {

  Future<void> folderFailSafe(final folder) async{
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
  }

  Future<File> getSpecJsonFile([String? specPath]) async {
    final baseDir = await getApplicationSupportDirectory();
    final appFolder = Directory('${baseDir.path}/TankPlannerPaths');
    folderFailSafe(appFolder);
    final fileName = '$specPath.json';
    return File('${appFolder.path}/$fileName');
  }

  Future<List<String>> loadFromDir() async{
    final baseDir = await getApplicationSupportDirectory();
    final appFolder = Directory('${baseDir.path}/TankPlannerPaths');
    folderFailSafe(appFolder);
    final folderContents = appFolder.listSync();

    final pathList = folderContents.whereType<File>()   
      .map((f) {
        final fileName = f.uri.pathSegments.last;    
        return fileName.replaceAll('.json', '');     
      })
      .toList();
    return pathList;
  }

  Future<void> saveToDir(String pathName, BuildContext context) async {
    final String defaultPath = 'assets/paths/example.json';
    final File referencePath = File(defaultPath);
    final createdFile = await getSpecJsonFile(pathName);
    await referencePath.exists() ? referencePath.copy(createdFile.path) : ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to reference: $referencePath')),
    );
  }

  Future<void> renamePathFile(String prevName, String newName, BuildContext context) async{
    final oldFile = await getSpecJsonFile(prevName);
    final newFile = await getSpecJsonFile(newName);
    await oldFile.exists() ? oldFile.copy(newFile.path) : ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to rename path: $oldFile')),
      );
    deletePathFile(prevName, context);
  }

  Future<void> deletePathFile(String delFile, BuildContext context) async {
    File toBeDeleted = await getSpecJsonFile(delFile);
    await toBeDeleted.exists() ? toBeDeleted.delete() : 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete path: $toBeDeleted')),
      );
  }
}