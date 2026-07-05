import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

final placeOrderDecider = Decider<PlaceOrderCommand, PlaceOrderState, Event>(
  initialState: const PlaceOrderState(),
  decide: (command, state) async* {
    if (state.restaurantId == null) {
      throw RestaurantNotFoundError(command.restaurantId);
    }
    if (state.orderPlaced) {
      throw OrderAlreadyExistsError(command.orderId);
    }
    if (state.menu == null) {
      throw RestaurantNotFoundError(command.restaurantId);
    }

    final menuItemIds = state.menu!.menuItems.map((item) => item.menuItemId).toSet();
    final unavailableItems = command.menuItems
        .where((item) => !menuItemIds.contains(item.menuItemId))
        .map((item) => item.menuItemId)
        .toList();

    if (unavailableItems.isNotEmpty) {
      throw MenuItemsNotAvailableError(unavailableItems);
    }

    yield RestaurantOrderPlacedEvent(
      restaurantId: command.restaurantId,
      orderId: command.orderId,
      menuItems: command.menuItems,
    );
  },
  evolve: (state, event) => switch (event) {
    RestaurantCreatedEvent(:final restaurantId, :final menu) => PlaceOrderState(restaurantId: restaurantId, menu: menu),
    RestaurantMenuChangedEvent(:final menu) => state.copyWith(menu: menu),
    RestaurantOrderPlacedEvent() => state.copyWith(orderPlaced: true),
    _ => state,
  },
);