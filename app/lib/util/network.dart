import 'package:app/util/notification.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class UnauthorizedRedirectInterceptor extends Interceptor {
  ///  Interceptor for redirecting to login page on 401 responses
  final BuildContext context;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ///    Redirect to login page and show snackbar
    if (err.response?.statusCode == 401) {
      showNotification(context, "Sesja wygasła.");
      context.go('/login');
    }
    handler.next(err);
  }

  UnauthorizedRedirectInterceptor(this.context);
}

Dio getDio(BuildContext context) {
  ///  Create Dio object with interceptor attached
  var dio = Dio();
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
  dio.interceptors.add(UnauthorizedRedirectInterceptor(context));
  return dio;
}
