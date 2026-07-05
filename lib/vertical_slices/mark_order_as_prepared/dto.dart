import '../../api.dart';
import '../../platform/server/json_parse.dart';
import 'command.dart';

ParseResult<MarkOrderAsPreparedCommand> parseMarkOrderAsPreparedCommand(
  Map<String, dynamic> json,
) {
  final orderIdResult = requiredString(json, 'orderId');
  if (orderIdResult is ParseError) return ParseError(orderIdResult.message);

  return ParseSuccess(
    MarkOrderAsPreparedCommand(
      orderId: OrderId((orderIdResult as ParseSuccess<String>).value),
    ),
  );
}