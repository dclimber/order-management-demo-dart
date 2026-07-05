import 'dart:convert';

import 'package:jaspr/server.dart';

import 'json_parse.dart';

Future<ParseResult<T>> parseRequestBody<T>(
  Request request,
  ParseResult<T> Function(Map<String, dynamic> json) parse,
) async {
  try {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return const ParseError('Request body is required');
    }
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      return const ParseError('Request body must be a JSON object');
    }
    return parse(json);
  } on FormatException catch (error) {
    return ParseError('Invalid JSON: ${error.message}');
  }
}
