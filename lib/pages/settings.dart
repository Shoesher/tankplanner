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
  String _selectedAppLanguage = 'English'; // Default language
  String _userName = 'User'; // Will load this if we want to display/change

  final List<String> _availableLanguages = ['English']; // Example languages
  final String _appVersion = '1.0.0'; // Example app version

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
      _selectedAppLanguage = prefs.getString('appLanguage') ?? 'English';
      _userName = prefs.getString('userName') ?? 'User'; // Load existing username
    });
  }

  // Generic function to save a single setting
  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
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
      _selectedAppLanguage = 'English';
      _userName = 'User';
      // Reset any other settings variables you might add to their defaults
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All app data has been cleared!'),
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
          title: const Text('Confirm Data Clear'),
          content: const Text(
              'Are you sure you want to clear all your progress, XP, and settings? This action cannot be undone.'),
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

  // Dialog for changing username
  void _showChangeUsernameDialog() {
    TextEditingController usernameController = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: 'Enter new username',
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
                if (usernameController.text.isNotEmpty) {
                  await _saveSetting('userName', usernameController.text);
                  setState(() {
                    _userName = usernameController.text; // Update UI immediately
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username cannot be empty!')),
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
              // --- General Preferences Section ---
              _buildSectionHeader('General Preferences'),
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                        subtitle: const Text('Toggle between light and dark themes'),
                        value: _darkModeEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                          _saveSetting('darkMode', value);
                          // For a full app, you would notify MaterialApp to change theme here
                        },
                        secondary: const Icon(Icons.dark_mode_outlined),
                        activeColor: Colors.blueAccent,
                      ),
                      const Divider(indent: 16, endIndent: 16), // Visual separator
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('App Language', style: TextStyle(fontSize: 18)),
                        subtitle: Text('Current: $_selectedAppLanguage'),
                        trailing: DropdownButton<String>(
                          value: _selectedAppLanguage,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedAppLanguage = newValue;
                              });
                              _saveSetting('appLanguage', newValue);
                              // For full localization, you'd update locale here
                            }
                          },
                          items: _availableLanguages.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Account Management Section ---
              _buildSectionHeader('Account Management'),
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Change Username', style: TextStyle(fontSize: 18)),
                      subtitle: Text('Current: $_userName'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showChangeUsernameDialog(); // Call the dialog for username change
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password', style: TextStyle(fontSize: 18)),
                      subtitle: const Text('Update your login password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Placeholder for change password logic (e.g., navigate to a new page)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change Password functionality coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // --- Data & Storage Section ---
              _buildSectionHeader('Data & Storage'),
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All App Data', style: TextStyle(fontSize: 18, color: Colors.red)),
                  subtitle: const Text('Resets all progress, XP, and settings to default.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showClearDataConfirmation, // Call the confirmation dialog
                ),
              ),

              // --- About Section ---
              _buildSectionHeader('About Tankplanner'),
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('App Version', style: TextStyle(fontSize: 18)),
                      subtitle: Text(_appVersion),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Privacy Policy', style: TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Placeholder for opening privacy policy in a browser or showing in-app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Privacy Policy (placeholder)!')),
                        );
                      },
                    ),
                     const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.gavel),
                      title: const Text('Licenses', style: TextStyle(fontSize: 18)),
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