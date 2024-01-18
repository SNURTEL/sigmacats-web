import 'package:flutter/material.dart';

DateTime clipDay(DateTime d) {
  ///  Clips day from a given date
  if (!DateUtils.isSameDay(d, DateTime.now())) {
    return DateTime.now().copyWith(hour: 23, minute: 59, second: 59, millisecond: 0, microsecond: 0);
  } else {
    return d;
  }
}
