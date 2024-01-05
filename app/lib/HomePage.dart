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
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'settings.dart' as settings;

import 'models/Race.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<RaceListEntry>> futureRaces;

  late Dio dio = getDio(context);

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaceList();
  }

  Future<List<RaceListEntry>> fetchRaceList() async {
    try {
      final response =
          // WHY DOES THIS EVEN WORK???????? HELP ???????? 127.0.0.11 IS DOCKER'S DNS, NOT BACKEND!!!!!!!
          await dio.get('${settings.apiBaseUrl}/api/coordinator/race/');
      final List<dynamic> races = response.data;
      return races.map((race) => RaceListEntry.fromMap(race)).toList();
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
            // padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 3.h),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Visibility(
                        visible: index == 0,
                        child: SizedBox(
                          height: 96,
                        )),
                    SizedBox(
                      width: max(min(40.h, 300), 600),
                      child: Card(
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
                                child: snapshot.data![index].event_graphic_file.contains("/")
                                    ? Image.network(
                                        '${settings.apiBaseUrl}${snapshot.data![index].event_graphic_file}',
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
                                          Text(
                                            snapshot.data![index].name,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            '${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(snapshot.data![index].start_timestamp.toString()))}-${DateFormat('HH:mm').format(DateTime.parse(snapshot.data![index].end_timestamp.toString()))}',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          Visibility(
                                            visible: snapshot.data![index].meetup_timestamp != null,
                                            child: Text(
                                              snapshot.data![index].meetup_timestamp != null
                                                  ? 'Zbiórka ${DateFormat('HH:mm').format(DateTime.parse(snapshot.data![index].meetup_timestamp.toString()))}'
                                                  : '',
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
                                              '${settings.apiBaseUrl}/api/coordinator/race/${snapshot.data![index].id}',
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
                                    snapshot.data![index].description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
