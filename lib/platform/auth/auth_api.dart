import '../../composition/api_registry.dart';
import '../server/api_response.dart';
import 'get_me_handler.dart';
import 'session.dart';
import 'session_context.dart';

/// Registers platform auth API routes (not a vertical slice).
void registerAuthApi(ApiRegistry registry) {
  registry.register(
    method: 'GET',
    path: '/me',
    handler: (request) async {
      final result = await handleGetMe(user: currentSessionUser);
      return toJsonResponse(result, encodeSessionUser);
    },
  );
}
