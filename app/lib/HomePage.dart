import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:math';
import 'package:app/network.dart';
import 'package:app/notification.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'settings.dart' as settings;

import 'models/RaceListRead.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<RaceListRead>> futureRaces;

  late Dio dio = getDio(context);

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaceList();
  }

  Future<List<RaceListRead>> fetchRaceList() async {
    try {
      final response = await dio.get('${settings.apiBaseUrl}/api/coordinator/race/');
      final List<dynamic> races = response.data;
      return races.map((race) => RaceListRead.fromMap(race)).toList();
    } on DioException catch (e) {
      print(e);
      throw Exception('Failed to load races');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureRaces,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          content = Center(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Visibility(
                        visible: index == 0,
                        child: SizedBox(
                          height: 96,
                        )),
                    SizedBox(width: max(min(40.h, 300), 600), child: RaceCard(snapshot.data![index], dio)),
                    SizedBox(height: 8.0),
                    Visibility(
                        visible: index == snapshot.data!.length - 1,
                        child: SizedBox(
                          height: 48,
                        )),
                  ],
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);
          content = Text('${snapshot.error}');
        } else {
          // By default, show a loading spinner.
          content = const CircularProgressIndicator();
        }

        return content;
      },
    );
  }
}

class RaceCard extends StatelessWidget {
  final RaceListRead race;
  final Dio dio;

  const RaceCard(this.race, this.dio, {super.key});

  @override
  Widget build(BuildContext context) {
    if (race.status == RaceStatus.ended && race.is_approved == false) {
      return FinishedCard(context);
    } else if (race.status == RaceStatus.ended) {
      return EndedCard(context);
    } else if (race.status == RaceStatus.in_progress) {
      return InProgressCard(context);
    } else {
      return PendingCard(context);
    }
  }

  Widget PendingCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5.0),
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          CardContent(context),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Row(children: [
                Text("Zatwierdź uczestników"),
                Spacer(),
                IconButton(
                    onPressed: () {
                      context.go("/race/${race.id}/participants");
                    },
                    icon: Icon(Icons.arrow_forward))
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget EndedCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5.0),
      child: ClipRect(
        child: Opacity(
            opacity: 0.62,
            child: CardContent(context),
        )
      ),
    );
  }

  Widget InProgressCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5.0),
      color: Colors.greenAccent.withOpacity(0.2),
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          CardContent(context),
          Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Właśnie trwa!"),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget FinishedCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5.0),
      color: Colors.orangeAccent.withOpacity(0.2),
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          CardContent(context),
          Container(
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Row(children: [
                Text("Zatwierdź wyniki"),
                Spacer(),
                IconButton(
                    onPressed: () {
                      context.go("/race/${race.id}");
                    },
                    icon: Icon(Icons.arrow_forward))
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget CardContent(BuildContext context) {
    return Column(children: [
      Container(
        // Fixed height
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: race.event_graphic_file.contains("/")
              ? Image.network(
                  '${settings.apiBaseUrl}${race.event_graphic_file}',
                  fit: BoxFit.fitWidth,
                )
              : Image.asset(
                  'res/sample_image.png',
                  fit: BoxFit.fitWidth,
                ),
        ),
      ),
      ListTile(
        contentPadding: const EdgeInsets.all(24.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: max(min(40.h, 300), 600) - 144),
                      child: Text(
                        race.name,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${DateFormat('dd.MM.yyyy HH:mm').format(race.start_timestamp)}-${DateFormat('HH:mm').format(race.end_timestamp)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Visibility(
                      visible: race.meetup_timestamp != null,
                      child: Text(
                        race.meetup_timestamp != null ? 'Zbiórka ${DateFormat('HH:mm').format(race.meetup_timestamp!)}' : '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                InkWell(
                  onTap: () async {
                    try {
                      final detailResponse = await dio.get(
                        '${settings.apiBaseUrl}/api/coordinator/race/${race.id}',
                      );
                      final gpxPath = detailResponse.data['checkpoints_gpx_file'];
                      html.window.open("${settings.apiBaseUrl}${gpxPath}", "dfsdf");
                    } on DioException catch (e) {
                      print(e);

                      showNotification(context, "Błąd");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_sharp,
                          size: 24,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Pokaż GPX",
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Text(
              race.description,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ],
        ),
      ),
    ]);
  }
}
