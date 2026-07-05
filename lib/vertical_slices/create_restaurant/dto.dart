import '../../api.dart';
import '../../platform/server/json_parse.dart';
import 'command.dart';

ParseResult<CreateRestaurantCommand> parseCreateRestaurantCommand(
  Map<String, dynamic> json,
) {
  final restaurantIdResult = requiredString(json, 'restaurantId');
  if (restaurantIdResult is ParseError) return ParseError(restaurantIdResult.message);

  final nameResult = requiredString(json, 'name');
  if (nameResult is ParseError) return ParseError(nameResult.message);

  final menuResult = parseMenu(json['menu']);
  if (menuResult is ParseError) return ParseError(menuResult.message);

  return ParseSuccess(
    CreateRestaurantCommand(
      restaurantId: RestaurantId((restaurantIdResult as ParseSuccess<String>).value),
      name: RestaurantName((nameResult as ParseSuccess<String>).value),
      menu: (menuResult as ParseSuccess<RestaurantMenu>).value,
    ),
  );
}