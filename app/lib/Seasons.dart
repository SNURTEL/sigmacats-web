import 'dart:js_util';
import 'dart:math';

import 'package:app/models/RaceDetailRead.dart';
import 'package:app/models/RaceListRead.dart';
import 'package:app/models/SeasonRead.dart';
import 'package:app/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'network.dart';
import 'settings.dart' as settings;

class SeasonsPage extends StatefulWidget {
  """
  Base class for creating season page widget
  """
  const SeasonsPage({Key? key}) : super(key: key);

  @override
  _SeasonsPageState createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
  """
  Creates widget for displaying and interacting with seasons
  """
  late Future<List<SeasonRead>> futureSeasons;

  late Dio dio = getDio(context);

  final newSeasonNameTextFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    futureSeasons = fetchSeasons();
  }

  Future<List<SeasonRead>> fetchSeasons() async {
    """
    Fetches league seasons from server
    """
    try {
      final response = await dio.get('${settings.apiBaseUrl}/api/coordinator/season/');
      final List<dynamic> races = response.data;
      return races.map((season) => SeasonRead.fromMap(season)).toList();
    } on DioException catch (e) {
      print(e);
      throw Exception('Failed to load seasons');
    }
  }

  @override
  Widget build(BuildContext context) {
    """
    Builds widget for displaying and interacting with seasons
    """
    return FutureBuilder(
      future: futureSeasons,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          final seasons = snapshot.data!;
          content = Content(context, seasons);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);
          content = Text('${snapshot.error}');
        } else {
          content = const CircularProgressIndicator();
        }

        return content;
      },
    );
  }

  Widget Content(BuildContext context, List<SeasonRead> seasons) {
    """
    Creates content for a widget that displays information about seasons
    """
    final seasonsSorted = seasons
      ..sort(((a, b) =>
      -a.startTimestamp
          .difference(b.startTimestamp)
          .inSeconds));
    final currentSeasonId = seasonsSorted.firstOrNull?.id;
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: max(min(40.h, 300), 600) - 32),
                              child: Text(
                                "Sezony",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .displayMedium,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 32,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: seasons.length,
                    itemBuilder: (context, index) {
                      final season = seasons[index];

                      final content = ListTile(
                        key: Key('$index'),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            seasons[index].name,
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Text(
                                            '${DateFormat('dd.MM.yyyy').format(season.startTimestamp)}' +
                                                (season.endTimestamp != null
                                                    ? " - ${DateFormat('dd.MM.yyyy').format(season.endTimestamp!)}"
                                                    : " - obecnie"),
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                        ],
                                      ),
                                      Spacer(),
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
                            season.id != currentSeasonId
                                ? Theme
                                .of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.62)
                                : Colors.transparent,
                            BlendMode.srcOver,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 64,),
                  SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                      ElevatedButton(onPressed: () {
                        newSeasonNameTextFieldController.clear();
                        showDialog(context: context, builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Zakończyć obecny sezon?"),
                            icon: Icon(Icons.edit_calendar_outlined),
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      "Rozpoczęcie nowego sezonu jest równoznaczne z zakończeniem poprzedniego. "
                                          "Zostaną utworzone nowe klasyfikacje dla uczestników. Tej operacji nie można cofnąć."),
                                  SizedBox(height: 8,),
                                  TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (seasons.map((e) => e.name).contains(value)) {
                                        return "Sezon o takiej nazwie już istnieje";
                                      }
                                      return (value?.isNotEmpty ?? true) ? null : "Pole wymagane";
                                    },
                                    controller: newSeasonNameTextFieldController,
                                    decoration: InputDecoration(
                                      hintText: "Nazwa nowego sezonu",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () {
                                Navigator.of(context).pop();
                              }, child: Text("Anuluj")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    foregroundColor: Theme.of(context).colorScheme.onError,
                                  ),
                                  onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    showNotification(context, 'Formularz zawiera błąd.');
                                    return;
                                  }

                                  final requestData = {
                                    'name': newSeasonNameTextFieldController.text
                                  };

                                  try {
                                    var response = await dio.post('${settings.apiBaseUrl}/api/coordinator/season/start-new', data: requestData);
                                    showNotification(context, 'Utworzono sezon ${newSeasonNameTextFieldController.text}!');
                                    setState(() {
                                      futureSeasons = fetchSeasons();
                                    });
                                    Navigator.of(context).pop();
                                  } on DioException catch (e) {
                                    print(e.error);
                                    print(e.message);
                                    showNotification(context, 'Błąd podczas tworzenia wyścigu.');
                                  }

                              }, child: Text("Rozpocznij nowy"))
                            ],

                          );
                        });
                      }, child: Text("Rozpocznij nowy"))

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
