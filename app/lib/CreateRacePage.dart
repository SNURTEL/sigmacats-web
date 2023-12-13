import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// import 'package:http/http.dart' as http;

import 'settings.dart' as settings;

import 'models/Race.dart';

class CreateRacePage extends StatefulWidget {
  const CreateRacePage({Key? key}) : super(key: key);

  @override
  _CreateRacePageState createState() => _CreateRacePageState();
}

class _CreateRacePageState extends State<CreateRacePage> {
  final dio = Dio();

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
              FilePickerResult? picked =
                  await FilePickerWeb.platform.pickFiles();

              if (picked == null) {
                print("No file picked");
                return;
              }

              print(picked.files.first.name);
              var bytes = picked.files.single.bytes!;

              FormData formData = FormData.fromMap({
                "fileobj": MultipartFile.fromBytes(bytes, filename: picked.files.first.name),
                "name": picked.files.first.name
              });
              var response = await dio.post("http://127.0.0.11:5050/api/upload-test/", data: formData);

              print(response.statusCode);
              print(response.data);

            },
            child: const Text('Select file'),
          )
        ],
      ),
    )));
  }
}
