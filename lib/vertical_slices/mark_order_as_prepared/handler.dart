import '../../api.dart';
import '../../platform/server/handler_result.dart';
import 'command.dart';
import 'errors.dart';
import 'service.dart';

Future<HandlerResult<List<OrderEvent>>> handleMarkOrderAsPrepared({
  required MarkOrderAsPreparedCommand command,
  required MarkOrderAsPreparedService service,
}) async {
  try {
    final events = await service.aggregate.handle(command).toList();
    return HandlerSuccess(events);
  } on OrderNotFoundError catch (error) {
    return HandlerError(404, error.toString());
  } on OrderAlreadyPreparedError catch (error) {
    return HandlerError(409, error.toString());
  }
}