import 'dart:convert';
import 'dart:math';

import 'package:app/network.dart';
import 'package:dio/browser.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'settings.dart' as settings;


import 'notification.dart';

class ForgotPasswordPage extends StatefulWidget {
  """
  Base class for creating a page for resetting password
  """
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  """
  Contains widget for resetting the password
  """

  final _formKey = GlobalKey<FormState>();
  final _emailEditingController = TextEditingController();

  var _showPassword = false;
  var _isLoading = false;

  late Dio dio = getDio(context);

  _ForgotPasswordPageState() : super();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    """
    Create widget for password resetting page
    """
    return Center(
        child: Scrollbar(
            child: SizedBox(
                width: max(min(40.h, 300), 600),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(
                      "Resetowanie hasła",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Wprowadź adres email powiązany z kontem - wyślemy do Ciebie wiadomość z linkiem do zresetowania hasła.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Flexible(
                      child: TextFormField(
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Adres email nie może być pusty.";
                          }
                          if (!RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                              .hasMatch(v)) {
                            return "Niepoprawny adres email.";
                          }
                          return null;
                        },
                        controller: _emailEditingController,
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Adres email", icon: Icon(Icons.person)),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  if (!_formKey.currentState!.validate()) {
                                    showNotification(context, 'Formularz zawiera błąd.');
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  var requestData = {
                                    "email": _emailEditingController.text,
                                  };

                                  try {
                                    await dio.post('${settings.apiBaseUrl}/api/auth/forgot-password', data: jsonEncode(requestData));
                                    showNotification(context, "Wysłano wiadomość! Sprawdź skrzynkę.");
                                  } on DioException catch (e) {
                                    // backend always returns 202
                                    showNotification(context, "Błąd podczas resetowania hasła.");
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });

                                },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Wyślij wiadomość"),
                          ),
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 32,
                        ),
                        TextButton(onPressed: _isLoading ? null : () {
                          context.go('/login');
                        }, child: Text("Powrót do ekranu logowania")),
                      ],
                    )
                  ]),
                ))));
  }
}
