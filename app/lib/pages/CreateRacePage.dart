import 'dart:convert';
import 'dart:math' as math;
import 'package:app/util/dates.dart';
import 'package:app/util/extensions.dart';
import 'package:app/util/notification.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:gpx/gpx.dart';
import 'dart:developer';

import '../components/NumberPicker.dart';
import '../util/network.dart';
import '../util/settings.dart' as settings;

class CreateRacePage extends StatefulWidget {
  ///  Base class for making a widget for creating a new race event
  const CreateRacePage({Key? key}) : super(key: key);

  @override
  _CreateRacePageState createState() => _CreateRacePageState();
}

class _CreateRacePageState extends State<CreateRacePage> {
  ///  Class for race creation page widget
  final nameEditingController = TextEditingController();
  final descriptionEditingController = TextEditingController();
  final requirementsEditingController = TextEditingController();
  final entryFeeEditingController = TextEditingController();
  final mapController = MapController();
  final placeToPointsMappingKeyController = TextEditingController();
  final placeToPointsMappingValueController = TextEditingController();
  final lastPlacePointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? uploadedGpxFilePath;
  Gpx? uploadedGpxObject;
  late List<Wpt> points;

  String? eventGraphicFilePath;
  Uint8List? eventGraphicBytes;

  Map<String, Uint8List> sponsorBanners = {};

  DateTime startDateTime = clipDay(DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0).add(Duration(hours: 1)));
  DateTime endDateTime = clipDay(DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0).add(Duration(hours: 3)));
  DateTime meetupDateTime = clipDay(DateTime.now().copyWith(second: 0, millisecond: 0, microsecond: 0).add(Duration(hours: 1)));

  bool isEventGraphicUploading = false;
  bool isRouteUploading = false;
  bool isSponsorBannerUploading = false;

  var noLaps = 1;

  final LAST_PLACE = 10000;
  late Map<int, int> placeToPointsMapping;

  @override
  void initState() {
    super.initState();
    placeToPointsMapping = {LAST_PLACE: 0};
    lastPlacePointsController.text = placeToPointsMapping[LAST_PLACE].toString();
  }

  var isAddEntryFeeChecked = false;
  var isAddMeetupHourChecked = false;

  late Dio dio = getDio(context);

  var isLoading = false;
  var successfullyCreated = false;
  String? gpxErrorMessage;
  String? eventGraphicErrorMessage;

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        tileProvider: CancellableNetworkTileProvider(),
      );

  @override
  Widget build(BuildContext context) {
    ///    Build a race creation page widget
    return SingleChildScrollView(
      child: Center(
          child: SizedBox(
        width: math.max(math.min(40.h, 300), 600),
        child: Column(
          children: [
            SizedBox(height: 48.0),
            Container(
                child: Row(
              children: [
                Flexible(
                  child: Text(
                    "Stwórz nowy wyścig",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ],
            )),
            SizedBox(height: 24.0),
            Text(
              "Zaplanuj swoje własne wyścigi i stwórz niezapomniane trasy przy użyciu naszej intuicyjnej platformy do "
              "organizacji wyścigów! Z łatwością wprowadzaj informacje, ustawiaj parametry trasy i personalizuj "
              "wydarzenie, aby spełnić oczekiwania zarówno doświadczonych kolarzy, jak i pasjonatów.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 64.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ///
                  /// Race title
                  ///
                  TextFormField(
                      controller: nameEditingController,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: InputDecoration(
                        hintText: "Nazwa wyścigu",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return (value?.isNotEmpty ?? true) ? null : "Pole wymagane";
                      }),
                  SizedBox(
                    height: 64,
                  ),

                  ///
                  /// Race event graphic
                  ///
                  Card(
                    child: Column(
                      children: [
                        FormField<String>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            var res = v == null || v.isEmpty ? "Nie wybrano grafiki wydarzenia." : null;
                            eventGraphicErrorMessage = res;
                            return res;
                          },
                          builder: (state) {
                            return InkWell(
                              onTap: isEventGraphicUploading
                                  ? null
                                  : () async {
                                      FilePickerResult? picked = await FilePickerWeb.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                                      );

                                      if (picked == null) {
                                        log("No file picked");
                                        return;
                                      }

                                      log(picked.files.first.name);
                                      var bytes = picked.files.single.bytes!;

                                      FormData formData = FormData.fromMap({
                                        "fileobj": MultipartFile.fromBytes(bytes, filename: picked.files.first.name),
                                        "name": picked.files.first.name
                                      });
                                      try {
                                        setState(() {
                                          isEventGraphicUploading = true;
                                        });
                                        var response = await dio
                                            .post("${settings.uploadBaseUrl}/api/coordinator/race/create/upload-graphic/", data: formData);

                                        log(response.data);
                                        var uploadedFileMeta = response.data;
                                        setState(() {
                                          isEventGraphicUploading = false;
                                          eventGraphicBytes = bytes;
                                          log("PATH IS ${uploadedFileMeta['fileobj.path']}");
                                          eventGraphicFilePath = uploadedFileMeta['fileobj.path'];
                                          state.setValue(uploadedFileMeta['fileobj.path']);
                                          eventGraphicErrorMessage = null;
                                        });
                                      } on DioException catch (e) {
                                        log("File upload error: ", error: e);
                                        showSnackbarMessage(context, "Błąd podczas przesyłania pliku.");
                                        setState(() {
                                          isEventGraphicUploading = false;
                                        });
                                        return;
                                      }
                                    },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                                child: Visibility(
                                  visible: eventGraphicBytes == null,
                                  replacement: eventGraphicBytes == null ? Container() : Image.memory(eventGraphicBytes!),
                                  child: SizedBox(
                                    height: 64.0,
                                    width: double.infinity,
                                    child: ColoredBox(
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      child: isEventGraphicUploading
                                          ? Center(child: CircularProgressIndicator())
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_photo_alternate_outlined),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text("Dodaj grafikę wydarzenia")
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Visibility(
                            visible: eventGraphicErrorMessage != null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                eventGraphicErrorMessage != null ? eventGraphicErrorMessage! : "",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.all(16),
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
                                maxLength: 2048,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  return (value?.isNotEmpty ?? true) ? null : "Pole wymagane";
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText:
                                        "Krótki opis zawierający postawowe informacje o wyścigu\n\t1. Zbiórka\n\t2. Przejazd trasy\n\t3. Wyłonie zwycięzcy"),
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
                                maxLines: 3,
                                maxLength: 512,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(), hintText: "Dodatkowe wymagania dla uczestników: kask, lampki, itp."),
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
                                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                      minLines: 1,
                                      maxLines: 1,
                                      decoration: InputDecoration(border: OutlineInputBorder(), hintText: "0 zł", suffixText: "zł"),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (s) {
                                        return s != null && s.isNotEmpty && int.parse(s) > 10000
                                            ? "Kwota nie może być większa niż 10.000zł"
                                            : null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),

                  ///
                  /// Race GPX track file
                  ///
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Trasa",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Card(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                uploadedGpxObject == null ? Theme.of(context).colorScheme.surface.withOpacity(0.62) : Colors.transparent,
                                BlendMode.srcOver,
                              ),
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                    initialCenter: LatLng(52.23202828872916, 21.006132649819673), // Warsaw
                                    initialZoom: 13,
                                    interactionOptions:
                                        InteractionOptions(flags: uploadedGpxObject != null ? InteractiveFlag.all : InteractiveFlag.none)),
                                children: [
                                  openStreetMapTileLayer,
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: uploadedGpxObject != null
                                            ? uploadedGpxObject!.trks.first.trksegs.first.trkpts
                                                .where((element) => element.lat != null && element.lon != null)
                                                .map((e) => LatLng(e.lat!, e.lon!))
                                                .toList()
                                            : [],
                                        strokeWidth: 3,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Row(
                              children: [
                                FormField<String>(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) {
                                    var result = v == null ? "Nie ustawiono trasy wyścigu." : null;
                                    if (result != null) {
                                      setState(() {
                                        gpxErrorMessage = "Nie ustawiono trasy wyścigu.";
                                      });
                                    }
                                    return result;
                                  },
                                  builder: (FormFieldState state) {
                                    return FilledButton(
                                      onPressed: isRouteUploading
                                          ? null
                                          : () async {
                                              FilePickerResult? picked = await FilePickerWeb.platform.pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['gpx'],
                                              );

                                              if (picked == null) {
                                                log("No file picked");
                                                return;
                                              }

                                              log(picked.files.first.name);
                                              var bytes = picked.files.single.bytes!;

                                              FormData formData = FormData.fromMap({
                                                "fileobj": MultipartFile.fromBytes(bytes, filename: picked.files.first.name),
                                                "name": picked.files.first.name
                                              });
                                              try {
                                                setState(() {
                                                  isRouteUploading = true;
                                                });

                                                log("${settings.uploadBaseUrl}/api/coordinator/race/create/upload-route/");
                                                var response = await dio.post(
                                                    "${settings.uploadBaseUrl}/api/coordinator/race/create/upload-route/",
                                                    data: formData);
                                                final Map<String, dynamic> uploadedFileMeta = response.data;
                                                log(response.data);

                                                setState(() {
                                                  isRouteUploading = false;
                                                  uploadedGpxFilePath = uploadedFileMeta['fileobj.path'];
                                                  log("PATH IS ${uploadedGpxFilePath}");
                                                  uploadedGpxObject = GpxReader().fromString(utf8.decode(bytes));
                                                  points = uploadedGpxObject!.trks.first.trksegs.first.trkpts;
                                                  log("GPX has ${points.length} trackpoints");

                                                  fitMap();
                                                  state.setValue(uploadedGpxFilePath);
                                                  gpxErrorMessage = null;
                                                });
                                              } on DioException catch (e) {
                                                log("File upload error: ", error: e);
                                                showSnackbarMessage(context, "Błąd podczas przesyłania pliku.");
                                                setState(() {
                                                  isRouteUploading = false;
                                                });
                                                return;
                                              }
                                            },
                                      child: isRouteUploading
                                          ? CircularProgressIndicator()
                                          : Row(
                                              children: [
                                                Icon(Icons.add),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text('Prześlij plik GPX')
                                              ],
                                            ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "Trasa powinna być pętlą.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Theme.of(context).textTheme.labelLarge?.color?.withOpacity(0.5)),
                                )
                              ],
                            ),
                            Visibility(
                                visible: gpxErrorMessage != null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    gpxErrorMessage != null ? gpxErrorMessage! : "",
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                                  ),
                                ))
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),

                  ///
                  /// Number of laps
                  ///
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
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

                  ///
                  /// Date and time
                  ///
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
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Row(
                          children: [
                            Flexible(
                              child: FormField<DateTime>(
                                autovalidateMode: AutovalidateMode.always,
                                validator: (v) {
                                  return v != null && !DateUtils.isSameDay(v, DateTime.now()) && v.isBefore(DateTime.now())
                                      ? "Nie można wybrać daty z przeszłości"
                                      : null;
                                },
                                builder: (FormFieldState state) {
                                  return InkWell(
                                    onTap: () async {
                                      var picked_s = await _selectDate(context, initialDate: startDateTime);
                                      if (picked_s != null && picked_s != startDateTime)
                                        setState(() {
                                          startDateTime =
                                              startDateTime.copyWith(day: picked_s.day, month: picked_s.month, year: picked_s.year);
                                          endDateTime =
                                              startDateTime.copyWith(day: picked_s.day, month: picked_s.month, year: picked_s.year);
                                          state.setValue(startDateTime);
                                        });
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.calendar_month),
                                        border: OutlineInputBorder(),
                                        errorText: state.errorText,
                                      ),
                                      child: Text(
                                          "${DateFormat.EEEE("pl_PL").format(startDateTime).capitalize()}, ${DateFormat.MMMMd("pl_PL").format(startDateTime)}"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 64,
                            ),
                            Icon(Icons.schedule),
                            SizedBox(
                              width: 16,
                            ),
                            Flexible(
                              child: FormField<Map<DateTime, DateTime>>(
                                  initialValue: {startDateTime: endDateTime},
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (v) {
                                    if (v == null) return null;
                                    var start = v.keys.first;
                                    var end = v.values.first;
                                    if (!end.isAfter(start)) {
                                      return "Niepoprawny czas trwania.";
                                    }
                                    if (end.isBefore(DateTime.now()) || start.isBefore(DateTime.now())) {
                                      return "Nie można wybrać godzin z przeszłości.";
                                    }
                                    return null;
                                  },
                                  builder: (FormFieldState state) {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(),
                                        errorText: state.errorText,
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              var picked_s = await _selectTime(context,
                                                  hintText: "Godzina rozpoczęcia",
                                                  initialTime: TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute));
                                              if (picked_s != null && picked_s != startDateTime) {
                                                setState(() {
                                                  startDateTime = startDateTime.copyWith(hour: picked_s.hour, minute: picked_s.minute);
                                                });
                                                state.setValue({startDateTime: endDateTime});
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                              child: Text(DateFormat.Hm("pl_PL").format(startDateTime).capitalize()),
                                            ),
                                          ),
                                          Text("-"),
                                          InkWell(
                                            onTap: () async {
                                              var picked_s = await _selectTime(context,
                                                  hintText: "Godzina zakończenia",
                                                  initialTime: TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute));
                                              if (picked_s != null && picked_s != endDateTime) {
                                                setState(() {
                                                  endDateTime = endDateTime.copyWith(hour: picked_s.hour, minute: picked_s.minute);
                                                });
                                                state.setValue({startDateTime: endDateTime});
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                              child: Text(DateFormat.Hm("pl_PL").format(endDateTime)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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
                              IntrinsicWidth(
                                child: FormField<DateTime>(
                                    initialValue: meetupDateTime,
                                    autovalidateMode: AutovalidateMode.always,
                                    validator: (v) {
                                      if (v == null) return null;
                                      if (v.isAfter(startDateTime)) {
                                        return "Błąd.";
                                      }
                                      if (meetupDateTime.isBefore(DateTime.now())) {
                                        return "Błąd.";
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState state) {
                                      return InkWell(
                                        onTap: () async {
                                          var picked_s = await _selectTime(context,
                                              hintText: "Czas zakończenia",
                                              initialTime: TimeOfDay(hour: meetupDateTime.hour, minute: meetupDateTime.minute));
                                          if (picked_s != null && picked_s != meetupDateTime) {
                                            setState(() {
                                              meetupDateTime = startDateTime.copyWith(hour: picked_s.hour, minute: picked_s.minute);
                                              state.setValue(meetupDateTime);
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            errorText: state.errorText,
                                            icon: Icon(Icons.schedule),
                                          ),
                                          child: Text(DateFormat.Hm("pl_PL").format(meetupDateTime).capitalize()),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(height: 24.0),

                  ///
                  /// Scoring
                  ///
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Punkty",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: placeToPointsMapping.length - 1,
                            itemBuilder: (context, index) {
                              var keysSorted = placeToPointsMapping.keys.where((element) => element != LAST_PLACE).toList();
                              keysSorted.sort();
                              var key = keysSorted[index];
                              return IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      (index == placeToPointsMapping.length - 1 || key == 1 ? "" : "≤ ") + key.toString(),
                                      textAlign: TextAlign.end,
                                    )),
                                    VerticalDivider(
                                      width: 20,
                                      indent: 5,
                                      endIndent: 5,
                                    ),
                                    Expanded(
                                      child: Text(placeToPointsMapping[key].toString() + " pkt."),
                                    ),
                                    SizedBox(width: 32),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            placeToPointsMapping.remove(key);
                                          });
                                        },
                                        icon: Icon(Icons.remove_circle_outline))
                                  ],
                                ),
                              );
                            }),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 48),
                              Expanded(
                                  child: Text(
                                "Dowolne",
                                textAlign: TextAlign.end,
                              )),
                              VerticalDivider(
                                width: 20,
                                indent: 5,
                                endIndent: 5,
                              ),
                              SizedBox(
                                width: 48,
                                child: TextFormField(
                                  controller: lastPlacePointsController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (v) {
                                    var parsed = v != null && lastPlacePointsController.text != "" ? int.parse(v) : 0;
                                    placeToPointsMapping[LAST_PLACE] = parsed;
                                    return v != null &&
                                            placeToPointsMapping.length > 1 &&
                                            v.isNotEmpty &&
                                            parsed >= placeToPointsMapping.values.where((e) => e != parsed).reduce(math.min)
                                        ? "Błąd."
                                        : null;
                                  },
                                  onTapOutside: (v) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      if (lastPlacePointsController.text == "") {
                                        placeToPointsMapping[LAST_PLACE] = 0;
                                        lastPlacePointsController.text = "0";
                                      } else {
                                        placeToPointsMapping[LAST_PLACE] = int.parse(lastPlacePointsController.text);
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 72),
                              Spacer()
                            ],
                          ),
                        ),
                        Text(
                          "Dodaj próg",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: TextField(
                                controller: placeToPointsMappingKeyController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                minLines: 1,
                                maxLines: 1,
                                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Miejsce (minimum)"),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: TextField(
                                controller: placeToPointsMappingValueController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                minLines: 1,
                                maxLines: 1,
                                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Punkty", suffixText: "pkt."),
                              ),
                            ),
                            SizedBox(width: 32),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    placeToPointsMapping[int.parse(placeToPointsMappingKeyController.text)] =
                                        int.parse(placeToPointsMappingValueController.text);
                                    placeToPointsMappingKeyController.clear();
                                    placeToPointsMappingValueController.clear();
                                  });
                                },
                                icon: Icon(Icons.add_circle_outline))
                          ],
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(height: 24.0),

                  ///
                  /// Sponsors
                  ///
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Sponsorzy",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: sponsorBanners.length,
                    itemBuilder: (context, index) {
                      var key = sponsorBanners.keys.toList()[index];
                      return IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                // constraints: BoxConstraints(maxWidth: 400),
                                child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(
                                          sponsorBanners[key]!,
                                          fit: BoxFit.fill,
                                        ))),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      sponsorBanners.remove(key);
                                    });
                                  },
                                  icon: Icon(Icons.remove_circle_outline))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Card(
                    child: InkWell(
                      onTap: isSponsorBannerUploading
                          ? null
                          : () async {
                              FilePickerResult? picked = await FilePickerWeb.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png'],
                              );

                              if (picked == null) {
                                log("No file picked");
                                return;
                              }

                              log(picked.files.first.name);
                              var bytes = picked.files.single.bytes!;

                              FormData formData = FormData.fromMap({
                                "fileobj": MultipartFile.fromBytes(bytes, filename: picked.files.first.name),
                                "name": picked.files.first.name
                              });
                              try {
                                setState(() {
                                  isSponsorBannerUploading = true;
                                });

                                var response =
                                    await dio.post("${settings.uploadBaseUrl}/api/coordinator/race/create/upload-graphic/", data: formData);
                                log(response.data);
                                var uploadedFileMeta = response.data;
                                var path = uploadedFileMeta['fileobj.path'];
                                setState(() {
                                  isSponsorBannerUploading = false;
                                  sponsorBanners[path] = bytes;
                                });
                              } on DioException catch (e) {
                                log("File upload error: ", error: e);
                                showSnackbarMessage(context, "Błąd podczas przesyłania pliku.");

                                setState(() {
                                  isSponsorBannerUploading = false;
                                });
                                return;
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isSponsorBannerUploading
                            ? CircularProgressIndicator()
                            : Row(
                                children: [Spacer(), Icon(Icons.add_circle_outline), SizedBox(width: 8), Text("Dodaj baner"), Spacer()],
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 48,
            ),

            ///
            /// "Create race" button
            ///
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

                            if (!_formKey.currentState!.validate()) {
                              showSnackbarMessage(context, 'Formularz zawiera błąd.');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            var requestData = {
                              "name": nameEditingController.text,
                              "description": descriptionEditingController.text,
                              "requirements": requirementsEditingController.text,
                              "meetup_timestamp": isAddMeetupHourChecked ? meetupDateTime.toUtc().toIso8601String() : null,
                              "start_timestamp": startDateTime.toUtc().toIso8601String(),
                              "end_timestamp": endDateTime.toUtc().toIso8601String(),
                              "entry_fee_gr": isAddEntryFeeChecked ? int.parse(entryFeeEditingController.text) * 100 : 0,
                              "no_laps": noLaps,
                              "checkpoints_gpx_file": uploadedGpxFilePath,
                              "event_graphic_file": eventGraphicFilePath,
                              "place_to_points_mapping_json": "[" +
                                  placeToPointsMapping.entries.map((e) => '{"place": ${e.key},"points": ${e.value}}').join(", ") +
                                  "]",
                              "sponsor_banners_uuids_json": "[${sponsorBanners.keys.map((e) => '"${e}"').join(', ')}]",
                              "season_id": 1
                            };
                            try {
                              var response = await dio.post('${settings.apiBaseUrl}/api/coordinator/race/create', data: requestData);
                              showSnackbarMessage(context, 'Utworzono wyścig ${nameEditingController.text}!');
                              setState(() {
                                successfullyCreated = true;
                              });
                              await Future.delayed(Duration(seconds: 4));
                              context.go('/');
                            } on DioException catch (e) {
                              log("Race creation error: ", error: e);
                              setState(() {
                                isLoading = false;
                              });
                              showSnackbarMessage(context, 'Błąd podczas tworzenia wyścigu.');
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

  @override
  void dispose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    requirementsEditingController.dispose();
    entryFeeEditingController.dispose();
    mapController.dispose();
    placeToPointsMappingKeyController.dispose();
    placeToPointsMappingValueController.dispose();
    lastPlacePointsController.dispose();
    super.dispose();
  }

  void fitMap() {
    ///    Fits the entire track in the window
    mapController.fitCamera(
      CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points.where((e) => e.lat != null && e.lon != null).map((e) => LatLng(e.lat!, e.lon!)).toList()),
          padding: EdgeInsets.all(32)),
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, {String? hintText, TimeOfDay? initialTime}) async {
    ///    Select time with dialog
    TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();
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

  Future<DateTime?> _selectDate(BuildContext context, {DateTime? initialDate}) async {
    ///    Select date with dialog
    DateTime selectedDate = initialDate ?? DateTime.now();
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
