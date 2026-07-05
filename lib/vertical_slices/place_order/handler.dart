import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'command.dart';
import 'errors.dart';
import 'service.dart';

Future<HandlerResult<List<Event>>> handlePlaceOrder({
  required PlaceOrderCommand command,
  required PlaceOrderService service,
}) async {
  try {
    final events = await service.aggregate.handle(command).toList();
    return HandlerSuccess(events, statusCode: 201);
  } on OrderAlreadyExistsError catch (error) {
    return HandlerError(409, error.toString());
  } on RestaurantNotFoundError catch (error) {
    return HandlerError(404, error.toString());
  } on MenuItemsNotAvailableError catch (error) {
    return HandlerError(422, error.toString());
  }
}