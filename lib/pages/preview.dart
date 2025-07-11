import 'package:flutter/material.dart';
import 'package:tankplanner/pages/settings.dart';

class Preview extends StatelessWidget {
  const Preview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tankplanner',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 71, 179),
        elevation: 0, //Removes shadow under the app bar
        //App bar icons
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 40,),
            onPressed: () {
              
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //User dashboard
              _buildStatsCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //   Widget _buildSideBar() {
  //   return Container(
  //     width: 250,
  //     color: const Color.fromARGB(255, 240, 240, 240),
  //     child: Column(
  //       children: [
  //         const DrawerHeader(
  //           child: Text('Menu', style: TextStyle(fontSize: 24)),
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.settings),
  //           title: const Text('Settings'),
  //           onTap: () {
  //             // Navigate to settings
  //             Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
  //             setState(() => _showSidebar = false);
  //           },
  //         ),
  //         // Add more items as needed
  //       ],
  //     ),
  //   );
  // }


  Widget _buildStatsCard(){
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SearchBar(
              leading: const Icon(Icons.search),
              hintText: 'Search for a path',
              elevation: WidgetStatePropertyAll(0),
            ),

            IconButton(
              icon: const Icon(Icons.folder_open_outlined, color: Colors.black, size: 50,),
              onPressed: () {
                //Add a new widget of a folder
              },
            ),

            IconButton(
              icon: const Icon(Icons.add_circle_outlined, color: Colors.black, size: 50,),
              onPressed: () {
                //Add a new widget of a path file
              },
            ),

          ],
        ),
      ),
    );
  }

}