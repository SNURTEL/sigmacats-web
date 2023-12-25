import 'package:app/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int selection=0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Witaj, Coordinator2!'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selection,
            onDestinationSelected: (int index) {
              setState(() {
                selection = index;
              });

              String route = switch (selection) {
                0 => "/",
                1 => "/create",
                _ => "/"
              };
              context.go(route);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Strona główna'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_bike),
                label: Text('Nowy wyścig'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profil'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
              child: Center(
                child: widget.child,
              )
          ),
        ],
      ),
    );
  }
}

