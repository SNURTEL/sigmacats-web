import 'package:app/AppScaffold.dart';
import 'package:app/CreateRacePage.dart';
import 'package:app/ForgotPasswordPage.dart';
import 'package:app/ResetPasswordPage.dart';
import 'package:app/theme/Color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'settings.dart' as settings;
import 'package:app/HomePage.dart';
import 'package:app/LoginPage.dart';

void main() async {
  await dotenv.load(fileName: "../.env");
  settings.apiBaseUrl = dotenv.env["FLUTTER_FASTAPI_HOST_URL"] ?? "http://localhost:8000";

  usePathUrlStrategy();
  initializeDateFormatting('pl_PL', null);
  runApp(App());
}

class App extends StatefulWidget {

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  _AppState() : super();


  late final _router = GoRouter(
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppScaffold(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
              path: '/',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return tweenWarpper(context, state, HomePage());
              }),
          GoRoute(
            path: '/create',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return tweenWarpper(context, state, CreateRacePage());
            },
          )
        ],
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return tweenWarpper(context, state, Scaffold(body: LoginPage()));
        },
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return tweenWarpper(context, state, Scaffold(body: ForgotPasswordPage()));
        },
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return tweenWarpper(context, state, Scaffold(body: ResetPasswordPage(
            state.uri.queryParameters['token'] ?? "dude-what"
          )));
        },
      ),
    ],
  );

  static CustomTransitionPage<void> tweenWarpper(BuildContext context, GoRouterState state, Widget childPage) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: childPage,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          routerConfig: _router,
        );
      },
    );
  }
}
