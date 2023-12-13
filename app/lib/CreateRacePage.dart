import 'dart:convert';
import 'dart:math';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import 'settings.dart' as settings;

import 'models/Race.dart';

class CreateRacePage extends StatefulWidget {
  const CreateRacePage({Key? key}) : super(key: key);

  @override
  _CreateRacePageState createState() => _CreateRacePageState();
}

class _CreateRacePageState extends State<CreateRacePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Start with a GPX file"),
          ElevatedButton(
            onPressed: () async {
              var picked = await FilePickerWeb.platform.pickFiles();

              if (picked != null) {
                print(picked.files.first.name);
              }
            },
            child: const Text('Select file'),)

        ],
      ),
    )));
  }
}
