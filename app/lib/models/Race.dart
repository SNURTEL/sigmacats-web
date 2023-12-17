enum RaceStatus {
  pending("pending"),
  in_progress("in_progress"),
  ended("ended"),
  cancelled("cancelled");

  const RaceStatus(this.value);
  final String value;


}

class RaceListEntry {
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

//<editor-fold desc="Data Methods">
  const RaceListEntry({
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
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RaceListEntry &&
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
          season_id == other.season_id);

  @override
  int get hashCode =>
      id.hashCode ^
      status.hashCode ^
      name.hashCode ^
      description.hashCode ^
      no_laps.hashCode ^
      meetup_timestamp.hashCode ^
      start_timestamp.hashCode ^
      end_timestamp.hashCode ^
      event_graphic_file.hashCode ^
      season_id.hashCode;

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
        '}';
  }

  RaceListEntry copyWith({
    int? id,
    RaceStatus? status,
    String? name,
    String? description,
    int? no_laps,
    DateTime? meetup_timestamp,
    DateTime? start_timestamp,
    DateTime? end_timestamp,
    String? event_graphic_file,
    int? season_id,
  }) {
    return RaceListEntry(
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
    );
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
    };
  }

  factory RaceListEntry.fromMap(Map<String, dynamic> map) {
    return RaceListEntry(
      id: map['id'] as int,
      status: RaceStatus.values.byName(map['status']),
      name: map['name'] as String,
      description: map['description'] as String,
      no_laps: map['no_laps'] as int,
      meetup_timestamp: map['meetup_timestamp'] != null ? DateTime.parse(map['meetup_timestamp']) : null,
      start_timestamp: DateTime.parse(map['start_timestamp']),
      end_timestamp: DateTime.parse(map['end_timestamp']),
      event_graphic_file: map['event_graphic_file'] as String,
      season_id: map['season_id'] as int,
    );
  }

//</editor-fold>
}
