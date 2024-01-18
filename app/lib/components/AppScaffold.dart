import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../util/network.dart';
import '../util/notification.dart';
import '../util/settings.dart' as settings;

class AppScaffold extends StatefulWidget {
  ///  Base class for AppScaffold, a widget wrapper for displaying navigation and general information on web app for coordinator
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  ///  Widget for displaying navigation and general information on the web app for coordinator
  int selection = 0;

  late bool isShowingNavRail = MediaQuery.of(context).size.width > 600;

  late Dio dio = getDio(context);

  @override
  Widget build(BuildContext context) {
    ///    Build the widget
    return Scaffold(
      appBar: AppBar(
        title: Text("Cześć!"),
      ),
      body: Stack(children: [
        Row(
          children: [
            Visibility(
              visible: isShowingNavRail,
              child: NavigationRail(
                selectedIndex: selection,
                onDestinationSelected: (int index) {
                  setState(() {
                    selection = index;
                  });

                  String route = switch (selection) { 0 => "/", 1 => "/create", 2 => "/seasons", _ => "/" };
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
                              showSnackbarMessage(context, "Wylogowano.");
                              context.go('/login');
                            } on DioException catch (e) {
                              log("Logout error: ", error: e);
                              showSnackbarMessage(context, "Błąd wylogowywania.");
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
                    icon: Icon(Icons.calendar_month),
                    label: Text('Sezon'),
                  ),
                ],
              ),
            ),
            VerticalDivider(thickness: 1, width: 1),
            Expanded(
                child: Center(
              child: widget.child,
            )),
          ],
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: isShowingNavRail ? 128 : 16),
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(isShowingNavRail ? Icons.arrow_back : Icons.menu),
                  onPressed: () {
                    setState(() {
                      isShowingNavRail = !isShowingNavRail;
                    });
                  },
                ),
              ),
            ))
      ]),
    );
  }
}
