import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scrollbar(
            child: SizedBox(
                width: max(min(40.h, 300), 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(
                        height: 64,
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: _usernameEditingController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Adres email", icon: Icon(Icons.person)),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Flexible(
                        child: TextFormField(
                          obscureText: !_showPassword,
                          controller: _passwordEditingController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: "Hasło", icon: Icon(Icons.password),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: IconButton(
                                icon: Icon(
                                  _showPassword ? Icons.visibility : Icons.visibility_off
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}
