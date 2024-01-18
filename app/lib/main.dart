import 'package:app/components/AppScaffold.dart';
import 'package:app/pages/ApproveParticipantsPage.dart';
import 'package:app/pages/CreateRacePage.dart';
import 'package:app/pages/ForgotPasswordPage.dart';
import 'package:app/pages/RaceResultsPage.dart';
import 'package:app/pages/ResetPasswordPage.dart';
import 'package:app/pages/SeasonsPage.dart';
import 'package:app/pages/HomePage.dart';
import 'package:app/pages/LoginPage.dart';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app/theme/Color.dart';
import 'util/settings.dart' as settings;

void main() async {
  ///  Runs the application
  await dotenv.load(fileName: "../.env");
  settings.apiBaseUrl = dotenv.env["FLUTTER_FASTAPI_HOST"] ?? "http://localhost:8000";
  settings.uploadBaseUrl =
      '${dotenv.env["FLUTTER_FASTAPI_HOST"] ?? "http://localhost"}:${dotenv.env["FLUTTER_FASTAPI_UPLOAD_PORT"] ?? 5050}';

  usePathUrlStrategy();
  initializeDateFormatting('pl_PL', null);
  runApp(App());
}

class App extends StatefulWidget {
  ///  App class used to build the application, includes states
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  _AppState() : super();

  ///  Class used for setting the initial state of the application, including page navigation

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
          ),
          GoRoute(
            path: '/race/:id',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return tweenWarpper(context, state, RaceResultsPage(int.parse(state.pathParameters['id']!)));
            },
          ),
          GoRoute(
            path: '/race/:id/participants',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return tweenWarpper(context, state, ApproveParticipantsPage(int.parse(state.pathParameters['id']!)));
            },
          ),
          GoRoute(
            path: '/seasons',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return tweenWarpper(context, state, SeasonsPage());
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
          return tweenWarpper(context, state, Scaffold(body: ResetPasswordPage(state.uri.queryParameters['token'] ?? "dude-what")));
        },
      ),
    ],
  );

  static CustomTransitionPage<void> tweenWarpper(BuildContext context, GoRouterState state, Widget childPage) {
    ///    Adds tween effect to page transition
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
    ///    Builds the whole application
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          title: "Sigma",
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          routerConfig: _router,
        );
      },
    );
  }
}
