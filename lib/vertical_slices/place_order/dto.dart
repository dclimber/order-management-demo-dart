import '../../api.dart';
import '../../platform/server/json_parse.dart';
import 'command.dart';

ParseResult<PlaceOrderCommand> parsePlaceOrderCommand(Map<String, dynamic> json) {
  final restaurantIdResult = requiredString(json, 'restaurantId');
  if (restaurantIdResult is ParseError) return ParseError(restaurantIdResult.message);

  final orderIdResult = requiredString(json, 'orderId');
  if (orderIdResult is ParseError) return ParseError(orderIdResult.message);

  final menuItemsResult = parseMenuItems(json['menuItems']);
  if (menuItemsResult is ParseError) return ParseError(menuItemsResult.message);

  return ParseSuccess(
    PlaceOrderCommand(
      restaurantId: RestaurantId((restaurantIdResult as ParseSuccess<String>).value),
      orderId: OrderId((orderIdResult as ParseSuccess<String>).value),
      menuItems: (menuItemsResult as ParseSuccess<List<MenuItem>>).value,
    ),
  );
}