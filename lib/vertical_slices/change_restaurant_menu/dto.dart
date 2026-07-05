import '../../api.dart';
import '../../platform/server/json_parse.dart';
import 'command.dart';

ParseResult<ChangeRestaurantMenuCommand> parseChangeRestaurantMenuCommand(
  Map<String, dynamic> json,
) {
  final restaurantIdResult = requiredString(json, 'restaurantId');
  if (restaurantIdResult is ParseError) return ParseError(restaurantIdResult.message);

  final menuResult = parseMenu(json['menu']);
  if (menuResult is ParseError) return ParseError(menuResult.message);

  return ParseSuccess(
    ChangeRestaurantMenuCommand(
      restaurantId: RestaurantId((restaurantIdResult as ParseSuccess<String>).value),
      menu: (menuResult as ParseSuccess<RestaurantMenu>).value,
    ),
  );
}