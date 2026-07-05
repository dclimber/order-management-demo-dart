import 'package:order_management_demo/platform/auth/get_me_handler.dart';
import 'package:order_management_demo/platform/server/handler_result.dart';
import 'package:order_management_demo/platform/auth/session.dart';
import 'package:test/test.dart';

void main() {
  test('handleGetMe returns user when authenticated', () async {
    final result = await handleGetMe(user: devSessionUser);

    expect(result, isA<HandlerSuccess<SessionUser>>());
    expect((result as HandlerSuccess<SessionUser>).value, devSessionUser);
  });

  test('handleGetMe returns 401 when unauthenticated', () async {
    final result = await handleGetMe(user: null);

    expect(result, isA<HandlerError>());
    expect((result as HandlerError).statusCode, 401);
  });
}
