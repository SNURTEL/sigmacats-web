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

class RaceResultsPage extends StatefulWidget {
  ///  Base class for a page with race results
    final int id;

  const RaceResultsPage(this.id, {Key? key}) : super(key: key);

  @override
  _RaceResultsPageState createState() => _RaceResultsPageState();
}

class _RaceResultsPageState extends State<RaceResultsPage> {
  ///  Creates a widget used for showing results of races
    late Future<RaceDetailRead> futureRace;
  late List<RaceParticipationRead> participations;

  late Dio dio = getDio(context);

  var confirmButtonEnabled = true;

  var pickedTemperature = RaceTemperature.normal;
  var pickedWind = RaceWind.zero;
  var pickedRain = RaceRain.zero;

  final temperatureNameMapping = {
    RaceTemperature.normal: "Komfortowa",
    RaceTemperature.cold: "Mróz (× 1,3)",
    RaceTemperature.hot: "Upał (× 1,3)",
  };

  final windNameMapping = {RaceWind.zero: "Brak", RaceWind.light: "Lekki (× 1,1)", RaceWind.heavy: "Huragan (× 1,4)"};

  final rainNameMapping = {RaceRain.zero: "Brak", RaceRain.light: "Lekki (× 1,3)", RaceRain.heavy: "Ulewa (× 2,0)"};

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
    ///    Build widget for showing the result of races
        return FutureBuilder(
      future: futureRace,
      builder: (context, snapshot) {
        late Widget content;
        if (snapshot.hasData) {
          final race = snapshot.data!;
          if (race.status == RaceStatus.ended && !race.is_approved) {
            content = Content(context, race);
          } else {
            content = Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("\"${race.name}\" nie wymaga zatwierdzenia wyników."),
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
    ///    Provides content for a widget displaying race results
        return SingleChildScrollView(
        child: Center(
            child: SizedBox(
                width: max(min(40.h, 300), 600),
                child: Column(
                  children: [
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
                                  race.name + " - wyniki",
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
                      height: 24,
                    ),
                    Text(
                      "Uwaga - wyniki są generowane w oparciu o czas dotarcia na metę wyścigu. "
                      "Z uwagi na niedokładność lokalizacji za pomocą systemu GPS w telefonach mogą nie odzwierciedlać rzeczywistości.\n\n"
                      "Przeciągnij pozycje na liście, aby zmodyfikować przypisanie miejsc. Dopuszczana jest klasyfikacja ex aequo, jeśli pierwotnie dwaj uczestnicy także byli sklasyfikowani ex aequo.",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.5)),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    ReorderableListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        for (int index = 0; index < participations.length; index += 1)
                          ListTile(
                            key: Key('$index'),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 64,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        (participations[index].place_assigned_overall ?? -1 + 1).toString(),
                                        style: Theme.of(context).textTheme.displaySmall,
                                      ),
                                      Visibility(
                                          visible:
                                              participations[index].place_generated_overall != participations[index].place_assigned_overall,
                                          child: Text(
                                            "(było ${participations[index].place_generated_overall})",
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ))
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
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
                                          Text((participations[index].time_seconds?.let((it) => it >= 3600
                                                  ? "${(it / 3600).floor()}h"
                                                  : "" + " ${(modulo(it, 3600) / 60).floor()}min ${modulo(it, 60)}s") ??
                                              ""))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16)
                              ],
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final RaceParticipationRead item = participations.removeAt(oldIndex);
                          participations.insert(newIndex, item);

                          var prevPlaceAssigned = 1;
                          var prevPlaceGenerated = 0;
                          for (var i = 0; i < participations.length; i++) {
                            if (participations[i].place_generated_overall == prevPlaceGenerated) {
                              participations[i].place_assigned_overall = prevPlaceAssigned;
                            } else {
                              participations[i].place_assigned_overall = i + 1;
                            }
                            prevPlaceAssigned = participations[i].place_assigned_overall!;
                            prevPlaceGenerated = participations[i].place_generated_overall ?? 0;
                          }
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              participations = (race.race_participations
                                        ?..sort((a, b) => (a.place_generated_overall ?? 0) - (b.place_generated_overall ?? 0)))
                                      ?.map((e) => e.copyWith(place_assigned_overall: e.place_generated_overall))
                                      .toList() ??
                                  [];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt),
                                SizedBox(
                                  width: 8,
                                ),
                                Text("Zresetuj")
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Row(
                      children: [
                        Text(
                          "Warunki pogodowe",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Jeśli pogoda na trasie pozostawiała wiele do życzenia, możesz przyznać dodatkowe punkty uczestnikom.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
                      final dropdowns = [
                        DropdownMenu<RaceTemperature>(
                          enableFilter: false,
                          enableSearch: false,
                          requestFocusOnTap: false,
                          label: Text("Temperatura"),
                          initialSelection: pickedTemperature,
                          onSelected: (RaceTemperature? value) {
                            setState(() {
                              pickedTemperature = value!;
                            });
                          },
                          dropdownMenuEntries: RaceTemperature.values.map<DropdownMenuEntry<RaceTemperature>>((RaceTemperature value) {
                            return DropdownMenuEntry<RaceTemperature>(value: value, label: temperatureNameMapping[value] ?? "");
                          }).toList(),
                        ),
                        DropdownMenu<RaceWind>(
                          enableFilter: false,
                          enableSearch: false,
                          requestFocusOnTap: false,
                          label: Text("Wiatr"),
                          initialSelection: pickedWind,
                          onSelected: (RaceWind? value) {
                            setState(() {
                              pickedWind = value!;
                            });
                          },
                          dropdownMenuEntries: RaceWind.values.map<DropdownMenuEntry<RaceWind>>((RaceWind value) {
                            return DropdownMenuEntry<RaceWind>(value: value, label: windNameMapping[value] ?? "");
                          }).toList(),
                        ),
                        DropdownMenu<RaceRain>(
                          enableFilter: false,
                          enableSearch: false,
                          requestFocusOnTap: false,
                          label: Text("Deszcz"),
                          initialSelection: pickedRain,
                          onSelected: (RaceRain? value) {
                            setState(() {
                              pickedRain = value!;
                            });
                          },
                          dropdownMenuEntries: RaceRain.values.map<DropdownMenuEntry<RaceRain>>((RaceRain value) {
                            return DropdownMenuEntry<RaceRain>(value: value, label: rainNameMapping[value] ?? "");
                          }).toList(),
                        ),
                      ];

                      if (MediaQuery.of(context).size.width > 550) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: dropdowns
                        );
                      } else {
                        return SizedBox(
                          height: 192,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: dropdowns,
                          ),
                        );
                      }
                    }),
                    SizedBox(
                      height: 64,
                    ),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                            onPressed: () => _confirmationDialogBuilder(context, () async {
                                  try {
                                    setState(() {
                                      confirmButtonEnabled = false;
                                    });
                                    await dio.patch('${settings.apiBaseUrl}/api/coordinator/race/${widget.id}',
                                        data: {"temperature": pickedTemperature.value, "rain": pickedRain.value, "wind": pickedWind.value});
                                    await dio.patch('${settings.apiBaseUrl}/api/coordinator/race/${widget.id}/participations',
                                        data: participations
                                            .map((p) => {"id": p.id, "place_assigned_overall": p.place_assigned_overall})
                                            .toList());
                                    showNotification(context, "Sukces!");
                                    await Future.delayed(Duration(seconds: 4));
                                    context.go("/");
                                  } on DioException catch (e) {
                                    setState(() {
                                      confirmButtonEnabled = true;
                                    });
                                    print(e);
                                    showNotification(context, "Błąd podczas zatwierdzania wyników.");
                                  }
                                }),
                            child: Text("Zatwierdź wyniki")))
                  ],
                ))));
  }

  Future<void> _confirmationDialogBuilder(BuildContext context, Future<void> Function() onConfirm) {
    ///    Builds dialog box for confirming the race results by coordinator
        return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wszystko gotowe?'),
          content: const Text(
            'Po przejściu dalej aplikacja zakończy wyścig i przydzieli uczestnikom punkty w klasyfikacjach. '
            'Tej operacji nie można cofnąć. Zmiana miejsc nie będzie już możliwa.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Anuluj',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Zakończ wyścig i przyznaj punkty',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
