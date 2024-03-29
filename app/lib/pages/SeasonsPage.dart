import 'dart:developer';
import 'dart:math' as math;

import 'package:app/models/RaceDetailRead.dart';
import 'package:app/models/SeasonRead.dart';
import 'package:app/util/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../util/network.dart';
import '../util/settings.dart' as settings;

class SeasonsPage extends StatefulWidget {
  const SeasonsPage({Key? key}) : super(key: key);

  @override
  _SeasonsPageState createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
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
    try {
      final response = await dio.get('${settings.apiBaseUrl}/api/coordinator/season/');
      final List<dynamic> races = response.data;
      return races.map((season) => SeasonRead.fromMap(season)).toList();
    } on DioException catch (e) {
      log("Season fetch error ", error: e);
      throw Exception('Failed to load seasons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureSeasons,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          final seasons = snapshot.data!;
          content = Content(context, seasons);
        } else if (snapshot.hasError) {
          log("Season fetch error: ", error: snapshot.error);
          content = Text('${snapshot.error}');
        } else {
          content = const CircularProgressIndicator();
        }

        return content;
      },
    );
  }

  Widget Content(BuildContext context, List<SeasonRead> seasons) {
    final seasonsSorted = seasons..sort(((a, b) => -a.startTimestamp.difference(b.startTimestamp).inSeconds));
    final currentSeasonId = seasonsSorted.firstOrNull?.id;
    return SingleChildScrollView(
        child: Center(
            child: SizedBox(
                width: math.max(math.min(40.h, 300), 600),
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
                              constraints: BoxConstraints(maxWidth: math.max(math.min(40.h, 300), 600) - 32),
                              child: Text(
                                "Sezony",
                                style: Theme.of(context).textTheme.displayMedium,
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
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          Text(
                                            '${DateFormat('dd.MM.yyyy').format(season.startTimestamp)}' +
                                                (season.endTimestamp != null
                                                    ? " - ${DateFormat('dd.MM.yyyy').format(season.endTimestamp!)}"
                                                    : " - obecnie"),
                                            style: Theme.of(context).textTheme.labelMedium,
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
                            season.id != currentSeasonId ? Theme.of(context).colorScheme.surface.withOpacity(0.62) : Colors.transparent,
                            BlendMode.srcOver,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 64,
                  ),
                  SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            newSeasonNameTextFieldController.clear();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Zakończyć obecny sezon?"),
                                    icon: Icon(Icons.edit_calendar_outlined),
                                    content: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Rozpoczęcie nowego sezonu jest równoznaczne z zakończeniem poprzedniego. "
                                              "Zostaną utworzone nowe klasyfikacje dla uczestników. Tej operacji nie można cofnąć."),
                                          SizedBox(
                                            height: 8,
                                          ),
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
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Anuluj")),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            foregroundColor: Theme.of(context).colorScheme.onError,
                                          ),
                                          onPressed: () async {
                                            if (!_formKey.currentState!.validate()) {
                                              showSnackbarMessage(context, 'Formularz zawiera błąd.');
                                              return;
                                            }

                                            final requestData = {'name': newSeasonNameTextFieldController.text};

                                            try {
                                              var response = await dio.post('${settings.apiBaseUrl}/api/coordinator/season/start-new',
                                                  data: requestData);
                                              showSnackbarMessage(context, 'Utworzono sezon ${newSeasonNameTextFieldController.text}!');
                                              setState(() {
                                                futureSeasons = fetchSeasons();
                                              });
                                              Navigator.of(context).pop();
                                            } on DioException catch (e) {
                                              log("Season creation error: ", error: e);
                                              showSnackbarMessage(context, 'Błąd podczas tworzenia sezonu.');
                                            }
                                          },
                                          child: Text("Rozpocznij nowy"))
                                    ],
                                  );
                                });
                          },
                          child: Text("Rozpocznij nowy")))
                ]))));
  }

  final statusToColorMapping = {
    RaceParticipationStatus.pending: Colors.transparent,
    RaceParticipationStatus.approved: Colors.greenAccent.withOpacity(0.2),
    RaceParticipationStatus.rejected: Colors.redAccent.withOpacity(0.2),
  };
}
