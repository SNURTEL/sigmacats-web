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

class ResetPasswordPage extends StatefulWidget {
  """
  Base class for creating a password allowing user to reset the password after clicking link in an email
  """
  final String token;


  const ResetPasswordPage(this.token, {Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  """
  Creates a widget that allows user to reset their password after clicking an email link
  """

  final _formKey = GlobalKey<FormState>();
  final _password1EditingController = TextEditingController();
  final _password2EditingController = TextEditingController();

  var _showPassword = false;
  var _isLoading = false;

  late Dio dio = getDio(context);

  _ResetPasswordPageState() : super();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    """
    Builds widget for resetting the password
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
                      "Ustaw nowe hasło do konta.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Flexible(
                      child: TextFormField(
                        obscureText: !_showPassword,
                        controller: _password1EditingController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Hasło nie może być puste.";
                          }
                          if (v.length < 8) {
                            return "Hasło musi zawierać co najmniej 8 znaków.";
                          }
                          if (v != _password2EditingController.text) {
                            return "Hasła nie są identyczne";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Hasło",
                            icon: Icon(Icons.password),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Flexible(
                      child: TextFormField(
                        obscureText: !_showPassword,
                        controller: _password2EditingController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Hasło nie może być puste.";
                          }
                          if (v.length < 8) {
                            return "Hasło musi zawierać co najmniej 8 znaków.";
                          }
                          if (v != _password1EditingController.text) {
                            return "Hasła nie są identyczne";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Potwierdź hasło",
                            icon: SizedBox(width: 24,),
                            ),
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
                                    "token": widget.token,
                                    "password": _password1EditingController.text,
                                  };

                                  try {
                                    await dio.post('${settings.apiBaseUrl}/api/auth/reset-password', data: jsonEncode(requestData));
                                    showNotification(context, 'Zresetowano hasło!');
                                    await Future.delayed(Duration(seconds: 4));
                                    context.go('/login');
                                  } on DioException catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    showNotification(context, 'Błąd resetowania hasła.');
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Ustaw nowe hasło"),
                          ),
                        ))
                  ]),
                ))));
  }
}
