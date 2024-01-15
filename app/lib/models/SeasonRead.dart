
import 'package:intl/intl.dart';

class SeasonRead {
  final int id;
  final String name;
  final DateTime startTimestamp;
  final DateTime? endTimestamp;

//<editor-fold desc="Data Methods">
  const SeasonRead({
    required this.id,
    required this.name,
    required this.startTimestamp,
    this.endTimestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeasonRead &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          startTimestamp == other.startTimestamp &&
          endTimestamp == other.endTimestamp);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ startTimestamp.hashCode ^ endTimestamp.hashCode;

  @override
  String toString() {
    return 'SeasonRead{' + ' id: $id,' + ' name: $name,' + ' startTimestamp: $startTimestamp,' + ' endTimestamp: $endTimestamp,' + '}';
  }

  SeasonRead copyWith({
    int? id,
    String? name,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
  }) {
    return SeasonRead(
      id: id ?? this.id,
      name: name ?? this.name,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'startTimestamp': this.startTimestamp,
      'endTimestamp': this.endTimestamp,
    };
  }

  factory SeasonRead.fromMap(Map<String, dynamic> map) {
    return SeasonRead(
      id: map['id'] as int,
      name: map['name'] as String,
      startTimestamp: DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['start_timestamp'], true).toLocal(),
      endTimestamp: map['end_timestamp'] != null ? DateFormat("yyyy-MM-ddTHH:mm:ss").parse(map['end_timestamp'], true).toLocal() : null,
    );
  }

//</editor-fold>
}