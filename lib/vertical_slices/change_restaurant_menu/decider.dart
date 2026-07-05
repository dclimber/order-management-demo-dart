import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

final changeRestaurantMenuDecider = Decider<ChangeRestaurantMenuCommand, ChangeRestaurantMenuState, RestaurantEvent>(
  initialState: const ChangeRestaurantMenuState(),
  decide: (command, state) async* {
    if (!state.exists) {
      throw RestaurantNotFoundError(command.restaurantId);
    }
    yield RestaurantMenuChangedEvent(
      restaurantId: command.restaurantId,
      menu: command.menu,
    );
  },
  evolve: (state, event) => switch (event) {
    RestaurantCreatedEvent(:final restaurantId) => ChangeRestaurantMenuState(restaurantId: restaurantId),
    _ => state,
  },
);