import 'package:intl/intl.dart';


enum RaceStatus {
  pending("pending"),
  in_progress("in_progress"),
  ended("ended"),
  cancelled("cancelled");

  const RaceStatus(this.value);

  final String value;
}

class RaceListRead {

  final int id;
  final RaceStatus status;
  final String name;
  final String description;
  final int no_laps;
  final DateTime? meetup_timestamp;
  final DateTime start_timestamp;
  final DateTime end_timestamp;
  final String event_graphic_file;
  final int season_id;
  final bool is_approved;

  const RaceListRead({
    required this.id,
    required this.status,
    required this.name,
    required this.description,
    required this.no_laps,
    this.meetup_timestamp,
    required this.start_timestamp,
    required this.end_timestamp,
    required this.event_graphic_file,
    required this.season_id,
    required this.is_approved,
  });

  @override
  bool operator ==(Object other) => // Overrides == operator to compare races
      identical(this, other) ||
      (other is RaceListRead &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          name == other.name &&
          description == other.description &&
          no_laps == other.no_laps &&
          meetup_timestamp == other.meetup_timestamp &&
          start_timestamp == other.start_timestamp &&
          end_timestamp == other.end_timestamp &&
          event_graphic_file == other.event_graphic_file &&
          season_id == other.season_id &&
          is_approved == other.is_approved);

  @override
  int get hashCode => // overrides get hashcode method
      id.hashCode ^
      status.hashCode ^
      name.hashCode ^
      description.hashCode ^
      no_laps.hashCode ^
      meetup_timestamp.hashCode ^
      start_timestamp.hashCode ^
      end_timestamp.hashCode ^
      event_graphic_file.hashCode ^
      season_id.hashCode ^
      is_approved.hashCode;

  @override
  String toString() {
    return 'RaceListEntry{' +
        ' id: $id,' +
        ' status: $status,' +
        ' name: $name,' +
        ' description: $description,' +
        ' no_laps: $no_laps,' +
        ' meetup_timestamp: $meetup_timestamp,' +
        ' start_timestamp: $start_timestamp,' +
        ' end_timestamp: $end_timestamp,' +
        ' event_graphic_file: $event_graphic_file,' +
        ' season_id: $season_id,' +
        ' is_approved: $is_approved,' +
        '}';
  }

  RaceListRead copyWith(
      {int? id,
      RaceStatus? status,
      String? name,
      String? description,
      int? no_laps,
      DateTime? meetup_timestamp,
      DateTime? start_timestamp,
      DateTime? end_timestamp,
      String? event_graphic_file,
      int? season_id,
      bool? is_approved}) {
    return RaceListRead(
        id: id ?? this.id,
        status: status ?? this.status,
        name: name ?? this.name,
        description: description ?? this.description,
        no_laps: no_laps ?? this.no_laps,
        meetup_timestamp: meetup_timestamp ?? this.meetup_timestamp,
        start_timestamp: start_timestamp ?? this.start_timestamp,
        end_timestamp: end_timestamp ?? this.end_timestamp,
        event_graphic_file: event_graphic_file ?? this.event_graphic_file,
        season_id: season_id ?? this.season_id,
        is_approved: is_approved ?? this.is_approved);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'status': this.status.value,
      'name': this.name,
      'description': this.description,
      'no_laps': this.no_laps,
      'meetup_timestamp': this.meetup_timestamp,
      'start_timestamp': this.start_timestamp,
      'end_timestamp': this.end_timestamp,
      'event_graphic_file': this.event_graphic_file,
      'season_id': this.season_id,
      'is_approved': this.is_approved,
    };
  }

  factory RaceListRead.fromMap(Map<String, dynamic> map) {
    return RaceListRead(
      id: map['id'] as int,
      status: RaceStatus.values.byName(map['status']),
      name: map['name'] as String,
      description: map['description'] as String,
      no_laps: map['no_laps'] as int,
      meetup_timestamp:
          map['meetup_timestamp'] != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['meetup_timestamp'], true).toLocal() : null,
      start_timestamp: DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['start_timestamp'], true).toLocal(),
      end_timestamp: DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['end_timestamp'], true).toLocal(),
      event_graphic_file: map['event_graphic_file'] as String,
      season_id: map['season_id'] as int,
      is_approved: map['is_approved'] as bool,
    );
  }

}
