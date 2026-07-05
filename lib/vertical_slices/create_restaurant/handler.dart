import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'command.dart';
import 'errors.dart';
import 'service.dart';

Future<HandlerResult<List<RestaurantEvent>>> handleCreateRestaurant({
  required CreateRestaurantCommand command,
  required CreateRestaurantService service,
}) async {
  try {
    final events = await service.aggregate.handle(command).toList();
    return HandlerSuccess(events, statusCode: 201);
  } on RestaurantAlreadyExistsError catch (error) {
    return HandlerError(409, error.toString());
  }
}