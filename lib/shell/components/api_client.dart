import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

sealed class ApiResponse {
  const ApiResponse();
}

final class ApiOk extends ApiResponse {
  const ApiOk(this.data);
  final dynamic data;
}

final class ApiFail extends ApiResponse {
  const ApiFail(this.message);
  final String message;
}

Future<ApiResponse> apiRequest({
  required String path,
  String method = 'GET',
  Map<String, dynamic>? body,
}) async {
  if (!kIsWeb) return const ApiFail('Not available on server');

  try {
    final init = web.RequestInit(method: method);
    if (body != null) {
      init.headers = {'Content-Type': 'application/json'}.jsify()! as web.HeadersInit;
      init.body = jsonEncode(body).toJS;
    }

    final response = await web.window.fetch(path.toJS, init).toDart;
    final text = (await response.text().toDart).toDart;

    if (!response.ok) {
      try {
        final errorJson = jsonDecode(text);
        if (errorJson is Map && errorJson['error'] != null) {
          return ApiFail(errorJson['error'].toString());
        }
      } catch (_) {}
      return const ApiFail('Request failed');
    }

    if (text.isEmpty) return const ApiOk(null);
    return ApiOk(jsonDecode(text));
  } catch (_) {
    return const ApiFail('Request failed');
  }
}

void notifyRestaurantCreated() {
  if (!kIsWeb) return;
  web.BroadcastChannel('restaurant-created').postMessage('refresh'.toJS);
}
