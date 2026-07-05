import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'command.dart';
import 'errors.dart';
import 'service.dart';

Future<HandlerResult<List<RestaurantEvent>>> handleChangeRestaurantMenu({
  required ChangeRestaurantMenuCommand command,
  required ChangeRestaurantMenuService service,
}) async {
  try {
    final events = await service.aggregate.handle(command).toList();
    return HandlerSuccess(events);
  } on RestaurantNotFoundError catch (error) {
    return HandlerError(404, error.toString());
  }
}