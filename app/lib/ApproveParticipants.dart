import 'dart:js_util';
import 'dart:math';

import 'package:app/models/RaceDetailRead.dart';
import 'package:app/models/RaceListRead.dart';
import 'package:app/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import 'network.dart';
import 'settings.dart' as settings;

class ApproveParticipantsPage extends StatefulWidget {
  ///  This class is used to create the basis of a page for approving participants
    final int id;

  const ApproveParticipantsPage(this.id, {Key? key}) : super(key: key);

  @override
  _ApproveParticipantsPageState createState() => _ApproveParticipantsPageState();
}

class _ApproveParticipantsPageState extends State<ApproveParticipantsPage> {
  ///  This class defines states of a page for approving participants
    late Future<RaceDetailRead> futureRace;
  late List<RaceParticipationRead> participations;

  late Dio dio = getDio(context);

  @override
  void initState() {
    super.initState();
    futureRace = fetchRace();
  }

  Future<RaceDetailRead> fetchRace() async {
    ///    Fetches races from server
        try {
      final response = await dio.get('${settings.apiBaseUrl}/api/coordinator/race/${widget.id}');
      final race = RaceDetailRead.fromMap(response.data);
      participations = (race.race_participations?..sort((a, b) => (a.place_generated_overall ?? 0) - (b.place_generated_overall ?? 0)))
              ?.map((e) => e.copyWith(place_assigned_overall: e.place_generated_overall))
              .toList() ??
          [];
      return race;
    } on DioException catch (e) {
      print(e);
      throw Exception('Failed to load races');
    }
  }

  @override
  Widget build(BuildContext context) {
    ///    Builds the widget for approving participants
        return FutureBuilder(
      future: futureRace,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          final race = snapshot.data!;
          if (race.status == RaceStatus.pending) {
            content = Content(context, race);
          } else {
            content = Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("\"${race.name}\" nie wymaga zatwierdzenia uczestników."),
                    SizedBox(
                      height: 8,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          context.go("/");
                        },
                        child: Text("Wróć na stronę główną"))
                  ],
                ),
              ),
            );
          }
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

  Widget Content(BuildContext context, RaceDetailRead race) {
    ///    Contains list of users to be accepted for a given race
        return SingleChildScrollView(
        child: Center(
            child: SizedBox(
                width: max(min(40.h, 300), 600),
                child: Column(children: [
                  SizedBox(
                    height: 128,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Flexible(
                                child: Text(
                                  race.name + " - uczestnicy",
                                  style: Theme.of(context).textTheme.displayMedium,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Zatwierdż uczestników, aby mogli wziąć udział w wyścigu.",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.5)),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: participations.length,
                    itemBuilder: (context, index) {

                      late Widget buttons;

                      if (participations[index].status != RaceParticipationStatus.pending) {
                        buttons = IconButton(
                            onPressed: () {
                              try {
                                dio.patch(
                                    '${settings.apiBaseUrl}/api/coordinator/race/${widget.id}/participations/${participations[index].id}/set-status',
                                    queryParameters: {'status': RaceParticipationStatus.pending.value});
                                setState(() {
                                  participations[index].status = RaceParticipationStatus.pending;
                                });
                              } on DioException catch (e) {
                                print(e);
                                throw Exception('Failed to load races');
                              }
                            },
                            icon: Icon(Icons.restart_alt));
                      } else {
                        buttons = Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  try {
                                    dio.patch(
                                        '${settings.apiBaseUrl}/api/coordinator/race/${widget.id}/participations/${participations[index].id}/set-status',
                                        queryParameters: {'status': RaceParticipationStatus.approved.value});
                                    setState(() {
                                      participations[index].status = RaceParticipationStatus.approved;
                                    });
                                  } on DioException catch (e) {
                                    print(e);
                                    throw Exception('Failed to load races');
                                  }
                                },
                                icon: Icon(Icons.done)),
                            IconButton(
                                onPressed: () {
                                  try {
                                    dio.patch(
                                        '${settings.apiBaseUrl}/api/coordinator/race/${widget.id}/participations/${participations[index].id}/set-status',
                                        queryParameters: {'status': RaceParticipationStatus.rejected.value});
                                    setState(() {
                                      participations[index].status = RaceParticipationStatus.rejected;
                                    });
                                  } on DioException catch (e) {
                                    print(e);
                                    throw Exception('Failed to load races');
                                  }
                                },
                                icon: Icon(Icons.close)),
                          ],
                        );
                      }

                      final content = ListTile(
                        key: Key('$index'),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Card(
                                color: statusToColorMapping[participations[index].status],
                                shadowColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            participations[index].rider_username,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          Text(
                                            "${participations[index].rider_name} ${participations[index].rider_surname}",
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      buttons
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16)
                          ],
                        ),
                      );

                      return ClipRRect(
                        child: ColorFiltered(
                          child: content,
                          colorFilter: ColorFilter.mode(
                            participations[index].status != RaceParticipationStatus.pending
                                ? Theme.of(context).colorScheme.surface.withOpacity(0.62)
                                : Colors.transparent,
                            BlendMode.srcOver,
                          ),
                        ),
                      );
                    },
                  )
                ]))));
  }

  final statusToColorMapping = {
    RaceParticipationStatus.pending: Colors.transparent,
    RaceParticipationStatus.approved: Colors.greenAccent.withOpacity(0.2),
    RaceParticipationStatus.rejected: Colors.redAccent.withOpacity(0.2),
  };
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
