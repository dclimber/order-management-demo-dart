import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'state.dart';

final restaurantView = View<RestaurantViewState?, RestaurantEvent>(
  initialState: null,
  evolve: (state, event) => switch (event) {
    RestaurantCreatedEvent(
      :final restaurantId,
      :final name,
      :final menu,
    ) =>
      RestaurantViewState(
        restaurantId: restaurantId,
        name: name,
        menu: menu,
      ),
    RestaurantMenuChangedEvent(:final menu) =>
      state != null
          ? RestaurantViewState(
              restaurantId: state.restaurantId,
              name: state.name,
              menu: menu,
            )
          : null,
  },
);
