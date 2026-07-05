import '../server/handler_result.dart';
import 'session.dart';

Future<HandlerResult<SessionUser>> handleGetMe({required SessionUser? user}) async {
  if (user == null) {
    return const HandlerError(401, 'Unauthorized');
  }
  return HandlerSuccess(user);
}
