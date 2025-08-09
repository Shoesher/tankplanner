// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget { // Changed to StatefulWidget
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  // State variables for various settings
  bool _darkModeEnabled = false;
  final List<String> _fieldOptions = ['Reefscape', 'Crescendo', 'Charged Up', 'Rapid Reacts']; // Default language
  final List<String> _motorOptions = ['NEO', 'CIM', 'KrakenX60'];
  String _selectedField = 'Reefscape';
  String _selectedMotor = 'NEO';
  double _robotMass = 74.1;
  double _robotLength = 0.6;
  double _robotWidth = 0.5;
  double _robotRatio = 8;
  double _bumperWidth = 0.15;
  double _wheelRadius = 0.048;
  final String _appVersion = '1.0.0'; 

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved settings when the page initializes
  }

  // Function to load all settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _selectedField = prefs.getString('fieldType') ?? 'Reefscape';
      _selectedMotor = prefs.getString('motorType') ?? 'NEO'; 
    });
  }

  // Generic function to save a single setting
  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } 
    else if (value is String) {
      await prefs.setString(key, value);
    }
    else if(value is double){
      await prefs.setDouble(key, value);
    }
    // You can add more types (int, double) if needed for other settings
  }

  // Function to clear all app data
  Future<void> _clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears ALL stored SharedPreferences data

    // Reset local state variables to their default values after clearing
    setState(() {
      _darkModeEnabled = false;
      _selectedField = _fieldOptions[0];
      _selectedMotor = _motorOptions[0];
      _robotMass = 74.1;
      _robotLength = 0.6;
      _robotWidth = 0.5;
      _robotRatio = 8;
      _bumperWidth = 0.15;
      _wheelRadius = 0.048;
      // Reset any other settings variables you might add to their defaults
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data reset'),
        backgroundColor: Colors.green,
      ),
    );
    // You might want to navigate the user back to the homepage or prompt a restart
    // for the changes to fully take effect across the app.
  }

  // Dialog to confirm clearing data
  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Data Reset'),
          content: const Text(
              'Are you sure you want to clear all of your data? All of your config settings will be restored to their defaults.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _clearAllData(); // Perform the clear action
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String getUnit(int tab){
    String a;
    if(tab == 0){
      a = 'KG';
      return a;
    }
    else{
      a = 'M';
      return a;
    }
  } 

  // Dialog for changing username
  void _showSettingsDialog(int action) {
    TextEditingController massController = TextEditingController(text: _robotMass.toString());
    TextEditingController r_LengthController = TextEditingController(text: _robotLength.toString());
    TextEditingController r_WidthController = TextEditingController(text: _robotWidth.toString());
    TextEditingController b_WidthController = TextEditingController(text: _bumperWidth.toString());
    TextEditingController ratioController = TextEditingController(text: _robotRatio.toString());
    TextEditingController radiusController = TextEditingController(text: _wheelRadius.toString());

    List<TextEditingController> settingsController = [massController, r_LengthController, r_WidthController, b_WidthController, ratioController, radiusController];
    List<String> sharedPrefs = ['botMass', 'botLength', 'botWidth', 'botBumper', 'botRatio', 'botWheels'];
    String unit = getUnit(action);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Value ($unit)'),
          content: TextField(
            controller: settingsController[action],
            decoration: const InputDecoration(
              hintText: 'aifjiajf',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (settingsController[action].text.isNotEmpty) {
                  double? parsedValue = double.tryParse(settingsController[action].text);
                  if (parsedValue != null) {
                    await _saveSetting(sharedPrefs[action], parsedValue);
                    setState(() {
                      switch (action) {
                        case 0: _robotMass = parsedValue; break;
                        case 1: _robotLength = parsedValue; break;
                        case 2: _robotWidth = parsedValue; break;
                        case 3: _bumperWidth = parsedValue; break;
                        case 4: _robotRatio = parsedValue; break;
                        case 5: _wheelRadius = parsedValue; break;
                      }
                    });
                  }
                  setState(() {
                    // _selectedMotor = settingsController[action].text; // Update UI immediately
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot be empty!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Settings',
           style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 71, 179),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), // Max width for content on desktop
          child: ListView(
            padding: const EdgeInsets.all(25.0), // Generous padding for content
            children: [
              //General app preferences
              _buildSectionHeader('General Preferences'),
              Card(
                color: const Color(0xFF2C2C2C),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode', style: TextStyle(fontSize: 18, color: Colors.white)),
                        subtitle: const Text('Toggle between light and dark themes', style: TextStyle(color: Colors.grey)),
                        value: _darkModeEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                          _saveSetting('darkMode', value);
                          // For a full app, you would notify MaterialApp to change theme here
                        },
                        secondary: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                        activeColor: Colors.blueAccent,
                      ),
                      const Divider(indent: 16, endIndent: 16), // Visual separator
                      ListTile(
                        leading: const Icon(Icons.gamepad, color: Colors.white),
                        title: const Text('Field Preference', style: TextStyle(fontSize: 18, color: Colors.white)),
                        subtitle: Text('Current: $_selectedField', style: TextStyle(color: Colors.grey)),
                        trailing: DropdownButton<String>(
                          value: _selectedField,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedField = newValue;
                              });
                              _saveSetting('fieldType', newValue);
                              // For full localization, you'd update locale here
                            }
                          },
                          items: _fieldOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Robot preferences
              _buildSectionHeader('Robot Configuration'),
              Card(
                color: const Color(0xFF2C2C2C),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bolt_outlined, color: Colors.white),
                      title: const Text('Motors', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Current: $_selectedMotor', style: TextStyle(color: Colors.grey)),
                      trailing: DropdownButton<String>(
                        value: _selectedMotor,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMotor = newValue;
                            });
                            _saveSetting('motorType', newValue);
                          }
                        },
                        items: _motorOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Robot Mass', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Mass: $_robotMass', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(0);
                      },
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Robot Length', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Length: $_robotLength', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(1);
                      },
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Robot Width', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Width: $_robotWidth', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(2);
                      },
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Bumper Width', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Width: $_bumperWidth', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(3);
                      },
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Gear Ratio', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Gear Ratio: $_robotRatio', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(4);
                      },
                    ),

                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.add_box_outlined, color: Colors.white),
                      title: const Text('Wheel Radius', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text('Radius: $_wheelRadius', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                          _showSettingsDialog(5);
                      },
                    ),
                  ],
                ),
              ),

              // --- Data & Storage Section ---
              _buildSectionHeader('Data & Storage'),
              Card(
                color: const Color(0xFF2C2C2C),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset', style: TextStyle(fontSize: 18, color: Colors.red)),
                  subtitle: const Text('Resets all app data and robot configuration settings.', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showClearDataConfirmation, // Call the confirmation dialog
                ),
              ),

              // --- About Section ---
              _buildSectionHeader('About Tankplanner'),
              Card(
                color: const Color(0xFF2C2C2C),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.white),
                      title: const Text('App Version', style: TextStyle(fontSize: 18, color: Colors.white)),
                      subtitle: Text(_appVersion, style: TextStyle(color: Colors.grey)),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.white),
                      title: const Text('Documentation', style: TextStyle(fontSize: 18, color: Colors.white)),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Placeholder for opening privacy policy in a browser or showing in-app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Tankplanner.ca')),
                        );
                      },
                    ),
                     const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.gavel, color: Colors.white),
                      title: const Text('Licenses', style: TextStyle(fontSize: 18, color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showLicensePage(context: context, applicationName: 'Native App');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}