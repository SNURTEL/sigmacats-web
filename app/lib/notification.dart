import 'package:flutter/material.dart';

void showNotification(BuildContext context, String message) {
  """
  Show notification
  """
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}