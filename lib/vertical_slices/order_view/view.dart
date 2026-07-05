import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'state.dart';

final orderView = View<OrderViewState?, OrderEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    RestaurantOrderPlacedEvent(
      :final orderId,
      :final restaurantId,
      :final menuItems,
    ) =>
      OrderViewState(
        orderId: orderId,
        restaurantId: restaurantId,
        menuItems: menuItems,
        status: OrderStatus.created,
      ),
    OrderPreparedEvent() =>
      state != null
          ? OrderViewState(
              orderId: state.orderId,
              restaurantId: state.restaurantId,
              menuItems: state.menuItems,
              status: OrderStatus.prepared,
            )
          : null,
  },
);
