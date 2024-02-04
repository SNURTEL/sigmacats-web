import 'dart:math' as math;

import 'package:app/util/network.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

import '../util/settings.dart' as settings;

import '../util/notification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();

  var _showPassword = false;
  var _isLoading = false;

  late Dio dio = getDio(context);

  _LoginPageState() : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scrollbar(
            child: SizedBox(
                width: math.max(math.min(40.h, 300), 600),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(
                      "Logowanie",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(
                      height: 64,
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
                        controller: _usernameEditingController,
                        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Adres email", icon: Icon(Icons.person)),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Flexible(
                      child: TextFormField(
                        obscureText: !_showPassword,
                        controller: _passwordEditingController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Hasło nie może być puste.";
                          }
                          if (v.length < 8) {
                            return "Hasło musi zawierać co najmniej 8 znaków.";
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
                                    showSnackbarMessage(context, 'Formularz zawiera błąd.');
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  var requestData = FormData.fromMap({
                                    "username": _usernameEditingController.text,
                                    "password": _passwordEditingController.text,
                                  });

                                  try {
                                    await dio.post('${settings.apiBaseUrl}/api/auth/cookie/login', data: requestData);
                                    var response = await dio.get('${settings.apiBaseUrl}/api/users/me');

                                    if (response.data["type"] != "coordinator") {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      showSnackbarMessage(context, 'Niepoprawne konto.');
                                      await dio.post('${settings.apiBaseUrl}/api/auth/cookie/logout');
                                      return;
                                    }

                                    context.go('/');
                                  } on DioException catch (e) {
                                    log("Login error: ", error: e);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (e.response?.statusCode == 400 && e.response?.data["detail"] == "LOGIN_BAD_CREDENTIALS") {
                                      showSnackbarMessage(context, 'Niepoprawny adres email bądź hasło.');
                                    } else {
                                      showSnackbarMessage(context, 'Błąd logowania.');
                                    }
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Zaloguj się"),
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
                        TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    context.go('/forgot-password');
                                  },
                            child: Text("Nie pamiętam hasła")),
                      ],
                    )
                  ]),
                ))));
  }
}
