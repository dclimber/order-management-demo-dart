import 'dart:convert';

import 'package:jaspr/server.dart';

import 'handler_result.dart';

Response toJsonResponse<T>(
  HandlerResult<T> result,
  Object Function(T value) encode,
) {
  return switch (result) {
    HandlerSuccess(:final value, :final statusCode) => Response(
      statusCode,
      body: jsonEncode(encode(value)),
      headers: jsonHeaders,
    ),
    HandlerError(:final statusCode, :final message) => jsonError(statusCode, message),
  };
}

Response jsonError(int statusCode, String message) => Response(
  statusCode,
  body: jsonEncode({'error': message}),
  headers: jsonHeaders,
);

const jsonHeaders = {'Content-Type': 'application/json'};
