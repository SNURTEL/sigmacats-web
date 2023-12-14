import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
// import 'package:http/http.dart' as http;

import 'components/NumberPicker.dart';
import 'settings.dart' as settings;

import 'models/Race.dart';

class CreateRacePage extends StatefulWidget {
  const CreateRacePage({Key? key}) : super(key: key);

  @override
  _CreateRacePageState createState() => _CreateRacePageState();
}

class _CreateRacePageState extends State<CreateRacePage> {
  final nameEditingController = TextEditingController();
  final descriptionEditingController = TextEditingController();
  final requirementsEditingController = TextEditingController();
  final entryFeeEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? uploadedGpxFilePath;

  DateTime startDateTime = DateTime.now()
      .copyWith(second: 0, millisecond: 0)
      .add(Duration(hours: 1));
  DateTime endDateTime = DateTime.now()
      .copyWith(second: 0, millisecond: 0)
      .add(Duration(hours: 3));
  DateTime meetupDateTime = DateTime.now()
      .copyWith(second: 0, millisecond: 0)
      .add(Duration(hours: 1));

  var noLaps = 1;

  var isAddEntryFeeChecked = false;
  var isAddMeetupHourChecked = false;

  final dio = Dio();

  var isLoading = false;
  var successfullyCreated = false;

  @override
  void dispose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    requirementsEditingController.dispose();
    entryFeeEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: SizedBox(
        width: max(min(40.h, 300), 600),
        child: Column(
          children: [
            SizedBox(height: 48.0),
            Container(
                child: Row(
              children: [
                Text(
                  "Stwórz nowy wyścig",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            )),
            SizedBox(height: 24.0),
            Text(
              "Zaplanuj swoje własne wyścigi i stwórz niezapomniane trasy przy użyciu naszej intuicyjnej platformy do organizacji wyścigów! Z łatwością wprowadzaj informacje, ustawiaj parametry trasy i personalizuj wydarzenie, aby spełnić oczekiwania zarówno doświadczonych kolarzy, jak i pasjonatów.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 64.0),
            Form(
              child: Column(
                children: [
                  TextFormField(
                      controller: nameEditingController,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: InputDecoration(
                        hintText: "Nazwa wyścigu",
                      ),
                      validator: (value) {
                        return (value?.isNotEmpty ?? true)
                            ? null
                            : "Pole wymagane";
                      }),
                  SizedBox(
                    height: 64,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Opis",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            controller: descriptionEditingController,
                            minLines: 2,
                            maxLines: 10,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Krótki opis zawierający postawowe informacje o wyścigu\n\t1. Zbiórka\n\t2. Przejazd trasy\n\t3. Wyłonie zwycięzcy"),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            "Wymagania (opcjonalne)",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            controller: requirementsEditingController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 2,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText:
                                    "Dodatkowe wymagania dla uczestników: kask, lampki, itp."),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Switch(
                                  value: isAddEntryFeeChecked,
                                  onChanged: (val) {
                                    setState(() {
                                      isAddEntryFeeChecked = val;
                                    });
                                  }),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Dodaj opłatę wpisową",
                                style: Theme.of(context).textTheme.labelLarge,
                              )
                            ],
                          ),
                          Visibility(
                            visible: isAddEntryFeeChecked,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: entryFeeEditingController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "0 zł",
                                      suffixText: "zł"),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Trasa",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: () async {
                                    FilePickerResult? picked =
                                        await FilePickerWeb.platform
                                            .pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['gpx'],
                                        );

                                    if (picked == null) {
                                      print("No file picked");
                                      return;
                                    }

                                    print(picked.files.first.name);
                                    var bytes = picked.files.single.bytes!;

                                    FormData formData = FormData.fromMap({
                                      "fileobj": MultipartFile.fromBytes(bytes,
                                          filename: picked.files.first.name),
                                      "name": picked.files.first.name
                                    });
                                    var response = await dio.post(
                                        "http://127.0.0.11:5050/api/upload-test/",
                                        data: formData);

                                    print(response.statusCode);
                                    print(response.data);
                                    if (response.statusCode == 200) {
                                      final Map<String, dynamic>
                                          uploadedFileMeta = response.data;
                                      setState(() {
                                        uploadedGpxFilePath =
                                            uploadedFileMeta['fileobj.path'];
                                        print("PATH IS ${uploadedGpxFilePath}");
                                      });
                                    }
                                    ;
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text('Prześlij plik GPX')
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Visibility(
                                    visible: uploadedGpxFilePath != null &&
                                        uploadedGpxFilePath!.isNotEmpty,
                                    child: Text(
                                      uploadedGpxFilePath != null
                                          ? uploadedGpxFilePath!
                                          : "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(128)),
                                    ))
                              ],
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Liczba okrążeń",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            NumericStepButton(
                              minValue: 1,
                              maxValue: 99,
                              onChanged: (val) {
                                noLaps = val;
                              },
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Czas",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    var picked_s = await _selectDate(context);
                                    if (picked_s != null &&
                                        picked_s != startDateTime)
                                      setState(() {
                                        startDateTime = startDateTime.copyWith(
                                            day: picked_s.day,
                                            month: picked_s.month,
                                            year: picked_s.year);
                                        endDateTime = startDateTime.copyWith(
                                            day: picked_s.day,
                                            month: picked_s.month,
                                            year: picked_s.year);
                                      });
                                  },
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_month),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                              "${DateFormat.EEEE("pl_PL").format(startDateTime).capitalize()}, ${DateFormat.MMMMd("pl_PL").format(startDateTime)}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          var picked_s = await _selectTime(
                                              context,
                                              hintText: "Czas rozpoczęcia");
                                          if (picked_s != null &&
                                              picked_s != startDateTime) {
                                            setState(() {
                                              startDateTime =
                                                  startDateTime.copyWith(
                                                      hour: picked_s.hour,
                                                      minute: picked_s.minute);
                                            });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              top: 16.0,
                                              bottom: 16.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.schedule),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(DateFormat.Hm("pl_PL")
                                                  .format(startDateTime)
                                                  .capitalize()),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          var picked_s = await _selectTime(
                                              context,
                                              hintText: "Czas zakończenia");
                                          if (picked_s != null &&
                                              picked_s != endDateTime) {
                                            setState(() {
                                              endDateTime =
                                                  endDateTime.copyWith(
                                                      hour: picked_s.hour,
                                                      minute: picked_s.minute);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              right: 16.0,
                                              top: 16.0,
                                              bottom: 16.0),
                                          child: Text(" - " +
                                              DateFormat.Hm("pl_PL")
                                                  .format(endDateTime)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Switch(
                                    value: isAddMeetupHourChecked,
                                    onChanged: (val) {
                                      setState(() {
                                        isAddMeetupHourChecked = val;
                                      });
                                    }),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Dodaj godzinę zbiórki",
                                  style: Theme.of(context).textTheme.labelLarge,
                                )
                              ],
                            ),
                            Visibility(
                              visible: isAddMeetupHourChecked,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var picked_s = await _selectTime(context,
                                          hintText: "Czas zakończenia");
                                      if (picked_s != null &&
                                          picked_s != meetupDateTime) {
                                        setState(() {
                                          meetupDateTime =
                                              startDateTime.copyWith(
                                                  hour: picked_s.hour,
                                                  minute: picked_s.minute);
                                        });
                                      }
                                    },
                                    child: Card(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.schedule),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(DateFormat.Hm("pl_PL")
                                                .format(meetupDateTime)
                                                .capitalize()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
            ),
            SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            var requestData = {
                              "name": nameEditingController.text,
                              "description": descriptionEditingController.text,
                              "requirements":
                                  requirementsEditingController.text,
                              "meetup_timestamp": isAddMeetupHourChecked
                                  ? meetupDateTime.toIso8601String()
                                  : null,
                              "start_timestamp":
                                  startDateTime.toIso8601String(),
                              "end_timestamp": endDateTime.toIso8601String(),
                              "entry_fee_gr": isAddEntryFeeChecked
                                  ? int.parse(entryFeeEditingController.text) *
                                      100
                                  : 0,
                              "no_laps": noLaps,
                              // FIXME hardcoded for now
                              "place_to_points_mapping_json":
                                  '[{"place": 1,"points": 20}, {"place": 999,"points": 0}]',
                              "sponsor_banners_uuids_json": "[]",
                              "season_id": 1
                            };
                            try {
                              var response = await dio.post(
                                  '${settings.apiBaseUrl}/api/coordinator/race/create',
                                  data: requestData);
                              print(response.statusCode);
                              print(response.data);
                              showNotification(
                                  context, 'Utworzono wyścig ${nameEditingController.text}!');
                              setState(() {
                                successfullyCreated=true;
                              });
                              await Future.delayed(Duration(seconds: 4));
                              context.go('/');
                            } on DioException catch (e) {
                              print(e.response?.statusCode);
                              print(e.response?.data);
                              print(e.error);
                              print(e.message);
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bike),
                        SizedBox(
                          width: 8,
                        ),
                        Text(successfullyCreated ? "Sukces!" : "Stwórz wyścig"),
                      ],
                    ))),
            SizedBox(
              height: 96,
            )
          ],
        ),
      )),
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context,
      {String? hintText}) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        helpText: hintText,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          );
        });
    return picked_s;
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked_s = await showDatePicker(
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
        context: context,
        initialDate: selectedDate,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          );
        });
    return picked_s;
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

void showNotification(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
