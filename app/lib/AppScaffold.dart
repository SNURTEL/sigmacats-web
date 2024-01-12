import 'package:app/HomePage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'network.dart';
import 'notification.dart';
import 'settings.dart' as settings;


class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int selection = 0;

  late Dio dio = getDio(context);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cześć!"),
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
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        try {
                          dio.post("${settings.apiBaseUrl}/api/auth/cookie/logout");
                          showNotification(context, "Wylogowano.");
                          context.go('/login');
                        } on DioException catch (e) {
                          print(e.response?.statusCode);
                          print(e.response?.data);
                          showNotification(context, "Błąd wylogowywania.");
                          return;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.logout),
                            Text(
                              "Wyloguj",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
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

