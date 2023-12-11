import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import 'models/Race.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Coordinator',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: RaceList(),
          );();
        }
    );
  }
}

class RaceList extends StatefulWidget {
  const RaceList({Key? key}) : super(key: key);

  @override
  _RaceListState createState() => _RaceListState();
}

class _RaceListState extends State<RaceList> {
  late Future<List<RaceListEntry>> futureRaces;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaceList();
  }

  Future<List<RaceListEntry>> fetchRaceList() async {
    final response =
        await http.get(Uri.parse('http://localhost/api/coordinator/race/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the races from the response
      final List<dynamic> races = json.decode(utf8.decode(response.bodyBytes));
      return races.map((race) => RaceListEntry.fromMap(race)).toList();
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load races');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, <username>!'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: _getPage(_selectedIndex, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        return _buildPage(context);
      case 1:
        return _buildPage(context);
      case 2:
        return _buildPage(context);
    }
    return null;
  }

  Widget _buildPage(BuildContext context) {
    return FutureBuilder(
      future: futureRaces,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          content = Center(
            // padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 3.h),
            child: Scrollbar(
              child: SizedBox(
                width: max(min(40.h, 300), 600),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return
                      Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 160.0,
                                  // Fixed height
                                  width: double.infinity,
                                  // Fill the available width
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16.0),
                                      topRight: Radius.circular(16.0),
                                    ),
                                    child: Image.asset(
                                      'res/sample_image.png',
                                      fit: BoxFit
                                          .fitWidth, // Ensure the image fills the container
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data![index].name,
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          // Adjust the font size as needed
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        snapshot.data![index].meetup_timestamp
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // Add space between list elements
                        ],
                      );
                  },
                ),

              )
            ),
          );
        } else if (snapshot.hasError) {
          content = Text('${snapshot.error}');
        } else {
          // By default, show a loading spinner.
          content = const CircularProgressIndicator();
        }

        return content;
      },
    );
  }

  Widget _buildCard(String content) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
