import 'package:app/notification.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


class UnauthorizedRedirectInterceptor extends Interceptor {
  final BuildContext context;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      showNotification(context, "Sesja wygasła.");
      context.go('/login');
    }
    handler.next(err);
  }

  UnauthorizedRedirectInterceptor(this.context);
}


Dio getDio(BuildContext context) {
  var dio = Dio();
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
  dio.interceptors.add(UnauthorizedRedirectInterceptor(context));
  return dio;
}