import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

final createRestaurantDecider = Decider<CreateRestaurantCommand, CreateRestaurantState, RestaurantEvent>(
  initialState: const CreateRestaurantState(),
  decide: (command, state) async* {
    if (state.exists) {
      throw RestaurantAlreadyExistsError(command.restaurantId);
    }
    yield RestaurantCreatedEvent(
      restaurantId: command.restaurantId,
      name: command.name,
      menu: command.menu,
    );
  },
  evolve: (state, event) => switch (event) {
    RestaurantCreatedEvent(:final restaurantId) => CreateRestaurantState(
      restaurantId: restaurantId,
    ),
    _ => state,
  },
);