import 'package:intl/intl.dart';

import 'RaceListRead.dart';

///This file defines models for reading race details and race participation

enum RaceTemperature {
  ///  Holds different possible race temperatures

  normal("normal"),
  hot("hot"),
  cold("cold");

  const RaceTemperature(this.value);

  final String value;
}

enum RaceWind {
  ///  Holds different possible wind states

  zero("zero"),
  light("light"),
  heavy("heavy");

  const RaceWind(this.value);

  final String value;
}

enum RaceRain {
  ///  Holds different possible rain intensities during a race

  zero("zero"),
  light("light"),
  heavy("heavy");

  const RaceRain(this.value);

  final String value;
}

enum RaceParticipationStatus {
  ///  Holds different possible statuses of race participation

  pending("pending"),
  approved("approved"),
  rejected("rejected");

  const RaceParticipationStatus(this.value);

  final String value;
}

class RaceDetailRead {
  ///  Defines a class for reading race details

  final int id;
  final RaceStatus status;
  final String name;
  final String description;
  final String? requirements;
  final int no_laps;
  final DateTime? meetup_timestamp;
  final DateTime start_timestamp;
  final DateTime end_timestamp;
  final String event_graphic_file;
  final String checkpoints_gpx_file;
  final int entry_fee_gr;
  final List<RaceParticipationRead>? race_participations;
  final RaceTemperature? temperature;
  final RaceRain? rain;
  final RaceWind? wind;
  final String place_to_points_mapping_json;
  final String? sponsor_banners_uuids_json;
  final bool is_approved;

//<editor-fold desc="Data Methods">

  const RaceDetailRead({
    required this.id,
    required this.status,
    required this.name,
    required this.description,
    this.requirements,
    required this.no_laps,
    this.meetup_timestamp,
    required this.start_timestamp,
    required this.end_timestamp,
    required this.event_graphic_file,
    required this.checkpoints_gpx_file,
    required this.entry_fee_gr,
    this.race_participations,
    this.temperature,
    this.rain,
    this.wind,
    required this.place_to_points_mapping_json,
    this.sponsor_banners_uuids_json,
    required this.is_approved,
  });

  @override
  bool operator ==(Object other) => // Overrides == operator to compare races
      identical(this, other) ||
      (other is RaceDetailRead &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          name == other.name &&
          description == other.description &&
          requirements == other.requirements &&
          no_laps == other.no_laps &&
          meetup_timestamp == other.meetup_timestamp &&
          start_timestamp == other.start_timestamp &&
          end_timestamp == other.end_timestamp &&
          event_graphic_file == other.event_graphic_file &&
          checkpoints_gpx_file == other.checkpoints_gpx_file &&
          entry_fee_gr == other.entry_fee_gr &&
          race_participations == other.race_participations &&
          temperature == other.temperature &&
          rain == other.rain &&
          wind == other.wind &&
          place_to_points_mapping_json == other.place_to_points_mapping_json &&
          sponsor_banners_uuids_json == other.sponsor_banners_uuids_json &&
          is_approved == other.is_approved);

  @override
  int get hashCode => // overrides get hashcode method
      id.hashCode ^
      status.hashCode ^
      name.hashCode ^
      description.hashCode ^
      requirements.hashCode ^
      no_laps.hashCode ^
      meetup_timestamp.hashCode ^
      start_timestamp.hashCode ^
      end_timestamp.hashCode ^
      event_graphic_file.hashCode ^
      checkpoints_gpx_file.hashCode ^
      entry_fee_gr.hashCode ^
      race_participations.hashCode ^
      temperature.hashCode ^
      rain.hashCode ^
      wind.hashCode ^
      place_to_points_mapping_json.hashCode ^
      sponsor_banners_uuids_json.hashCode ^
      is_approved.hashCode;

  @override
  String toString() {
    ///    Converts race details into string

    return 'RaceDetailRead{' +
        ' id: $id,' +
        ' status: $status,' +
        ' name: $name,' +
        ' description: $description,' +
        ' requirements: $requirements,' +
        ' no_laps: $no_laps,' +
        ' meetup_timestamp: $meetup_timestamp,' +
        ' start_timestamp: $start_timestamp,' +
        ' end_timestamp: $end_timestamp,' +
        ' event_graphic_file: $event_graphic_file,' +
        ' checkpoints_gpx_file: $checkpoints_gpx_file,' +
        ' entry_fee_gr: $entry_fee_gr,' +
        ' race_participations: $race_participations,' +
        ' temperature: $temperature,' +
        ' rain: $rain,' +
        ' wind: $wind,' +
        ' place_to_points_mapping_json: $place_to_points_mapping_json,' +
        ' sponsor_banners_uuids_json: $sponsor_banners_uuids_json,' +
        ' is_approved: $is_approved,' +
        '}';
  }

  RaceDetailRead copyWith({
    int? id,
    RaceStatus? status,
    String? name,
    String? description,
    String? requirements,
    int? no_laps,
    DateTime? meetup_timestamp,
    DateTime? start_timestamp,
    DateTime? end_timestamp,
    String? event_graphic_file,
    String? checkpoints_gpx_file,
    int? entry_fee_gr,
    List<RaceParticipationRead>? race_participations,
    RaceTemperature? temperature,
    RaceRain? rain,
    RaceWind? wind,
    String? place_to_points_mapping_json,
    String? sponsor_banners_uuids_json,
    bool? is_approved,
  }) {
    ///    Copies details from one race to the other

    return RaceDetailRead(
      id: id ?? this.id,
      status: status ?? this.status,
      name: name ?? this.name,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      no_laps: no_laps ?? this.no_laps,
      meetup_timestamp: meetup_timestamp ?? this.meetup_timestamp,
      start_timestamp: start_timestamp ?? this.start_timestamp,
      end_timestamp: end_timestamp ?? this.end_timestamp,
      event_graphic_file: event_graphic_file ?? this.event_graphic_file,
      checkpoints_gpx_file: checkpoints_gpx_file ?? this.checkpoints_gpx_file,
      entry_fee_gr: entry_fee_gr ?? this.entry_fee_gr,
      race_participations: race_participations ?? this.race_participations,
      temperature: temperature ?? this.temperature,
      rain: rain ?? this.rain,
      wind: wind ?? this.wind,
      place_to_points_mapping_json: place_to_points_mapping_json ?? this.place_to_points_mapping_json,
      sponsor_banners_uuids_json: sponsor_banners_uuids_json ?? this.sponsor_banners_uuids_json,
      is_approved: is_approved ?? this.is_approved,
    );
  }

  Map<String, dynamic> toMap() {
    ///    Converts race details to map form

    return {
      'id': this.id,
      'status': this.status,
      'name': this.name,
      'description': this.description,
      'requirements': this.requirements,
      'no_laps': this.no_laps,
      'meetup_timestamp': this.meetup_timestamp,
      'start_timestamp': this.start_timestamp,
      'end_timestamp': this.end_timestamp,
      'event_graphic_file': this.event_graphic_file,
      'checkpoints_gpx_file': this.checkpoints_gpx_file,
      'entry_fee_gr': this.entry_fee_gr,
      'race_participations': this.race_participations,
      'temperature': this.temperature,
      'rain': this.rain,
      'wind': this.wind,
      'place_to_points_mapping_json': this.place_to_points_mapping_json,
      'sponsor_banners_uuids_json': this.sponsor_banners_uuids_json,
      'is_approved': this.is_approved,
    };
  }

  factory RaceDetailRead.fromMap(Map<String, dynamic> map) {
    ///    Reads race details from map

    return RaceDetailRead(
      id: map['id'] as int,
      status: RaceStatus.values.byName(map['status']),
      name: map['name'] as String,
      description: map['description'] as String,
      requirements: map['requirements'] as String?,
      no_laps: map['no_laps'] as int,
      meetup_timestamp: map['meetup_timestamp'] != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['meetup_timestamp'], true).toLocal() : null,
      start_timestamp: DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['start_timestamp'], true).toLocal(),
      end_timestamp: DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['end_timestamp'], true).toLocal(),
      event_graphic_file: map['event_graphic_file'] as String,
      checkpoints_gpx_file: map['checkpoints_gpx_file'] as String,
      entry_fee_gr: map['entry_fee_gr'] as int,
      race_participations: map['race_participations'].map<RaceParticipationRead>((e) => RaceParticipationRead.fromMap(e)).toList()
          as List<RaceParticipationRead>?,
      temperature: map['temperature'] != null ? RaceTemperature.values.byName(map['temperature']) : null,
      rain: map['rain'] != null ? RaceRain.values.byName(map['rain']) : null,
      wind: map['wind'] != null ? RaceWind.values.byName(map['wind']) : null,
      place_to_points_mapping_json: map['place_to_points_mapping_json'] as String,
      sponsor_banners_uuids_json: map['sponsor_banners_uuids_json'] as String,
      is_approved: map['is_approved'] as bool,
    );
  }

//</editor-fold>
}

class RaceParticipationRead {
  ///  Defines a class for reading race participations

  final int id;
  final int race_id;
  final int rider_id;
  final int bike_id;
  RaceParticipationStatus status;
  final int? place_generated_overall;
  int? place_assigned_overall;
  final String rider_name;
  final String rider_surname;
  final String rider_username;
  final int? time_seconds;

//<editor-fold desc="Data Methods">
  RaceParticipationRead({
    required this.id,
    required this.race_id,
    required this.rider_id,
    required this.bike_id,
    required this.status,
    this.place_generated_overall,
    this.place_assigned_overall,
    required this.rider_name,
    required this.rider_surname,
    required this.rider_username,
    this.time_seconds,
  });

  @override
  bool operator ==(Object other) => // Overrides == operator to compare races
      identical(this, other) ||
      (other is RaceParticipationRead &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          race_id == other.race_id &&
          rider_id == other.rider_id &&
          bike_id == other.bike_id &&
          status == other.status &&
          place_generated_overall == other.place_generated_overall &&
          place_assigned_overall == other.place_assigned_overall &&
          rider_name == other.rider_name &&
          rider_surname == other.rider_surname &&
          rider_username == other.rider_username &&
          time_seconds == other.time_seconds);

  @override
  int get hashCode => // overrides get hashcode method
      id.hashCode ^
      race_id.hashCode ^
      rider_id.hashCode ^
      bike_id.hashCode ^
      status.hashCode ^
      place_generated_overall.hashCode ^
      place_assigned_overall.hashCode ^
      rider_name.hashCode ^
      rider_surname.hashCode ^
      rider_username.hashCode ^
      time_seconds.hashCode;

  @override
  String toString() {
    ///    Converts race participation into string

    return 'RaceParticipationRead{' +
        ' id: $id,' +
        ' race_id: $race_id,' +
        ' rider_id: $rider_id,' +
        ' bike_id: $bike_id,' +
        ' status: $status,' +
        ' place_generated_overall: $place_generated_overall,' +
        ' place_assigned_overall: $place_assigned_overall,' +
        ' rider_name: $rider_name,' +
        ' rider_surname: $rider_surname,' +
        ' rider_username: $rider_username,' +
        ' time_seconds: $time_seconds,' +
        '}';
  }

  RaceParticipationRead copyWith({
    int? id,
    int? race_id,
    int? rider_id,
    int? bike_id,
    RaceParticipationStatus? status,
    int? place_generated_overall,
    int? place_assigned_overall,
    String? rider_name,
    String? rider_surname,
    String? rider_username,
    int? time_seconds,
  }) {
    ///    Copies race participation

    return RaceParticipationRead(
      id: id ?? this.id,
      race_id: race_id ?? this.race_id,
      rider_id: rider_id ?? this.rider_id,
      bike_id: bike_id ?? this.bike_id,
      status: status ?? this.status,
      place_generated_overall: place_generated_overall ?? this.place_generated_overall,
      place_assigned_overall: place_assigned_overall ?? this.place_assigned_overall,
      rider_name: rider_name ?? this.rider_name,
      rider_surname: rider_surname ?? this.rider_surname,
      rider_username: rider_username ?? this.rider_username,
      time_seconds: time_seconds ?? this.time_seconds,
    );
  }

  Map<String, dynamic> toMap() {
    ///    Converts race participation to map form
    
    return {
      'id': this.id,
      'race_id': this.race_id,
      'rider_id': this.rider_id,
      'bike_id': this.bike_id,
      'status': this.status,
      'place_generated_overall': this.place_generated_overall,
      'place_assigned_overall': this.place_assigned_overall,
      'rider_name': this.rider_name,
      'rider_surname': this.rider_surname,
      'rider_username': this.rider_username,
      'time_seconds': this.time_seconds,
    };
  }

  factory RaceParticipationRead.fromMap(Map<String, dynamic> map) {
    ///    Reads race participation from map

    return RaceParticipationRead(
        id: map['id'] as int,
        race_id: map['race_id'] as int,
        rider_id: map['rider_id'] as int,
        bike_id: map['bike_id'] as int,
        status: RaceParticipationStatus.values.byName(map['status']) as RaceParticipationStatus,
        place_generated_overall: map['place_generated_overall'] as int?,
        place_assigned_overall: map['place_assigned_overall'] as int?,
        rider_name: map['rider_name'] as String,
        rider_surname: map['rider_surname'] as String,
        rider_username: map['rider_username'] as String,
        time_seconds: map['time_seconds'] as int?);
  }

//</editor-fold>
}
