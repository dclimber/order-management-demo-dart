import '../vertical_slices/change_restaurant_menu/module.dart';
import '../vertical_slices/create_restaurant/module.dart';
import '../vertical_slices/mark_order_as_prepared/module.dart';
import '../vertical_slices/order_view/module.dart';
import '../vertical_slices/place_order/module.dart';
import '../vertical_slices/restaurant_view/module.dart';
import 'vertical_slice.dart';

/// Central composition root — the only place that wires all slices (D2).
///
/// Deleting a slice: remove its import and entry here.
const allSlices = <VerticalSlice>[
  RestaurantViewSlice(),
  OrderViewSlice(),
  CreateRestaurantSlice(),
  ChangeRestaurantMenuSlice(),
  PlaceOrderSlice(),
  MarkOrderAsPreparedSlice(),
];
