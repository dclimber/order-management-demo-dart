// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:order_management_demo/shell/components/theme_toggle.dart'
    deferred as _theme_toggle;
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/ui/change_menu_form.dart'
    deferred as _change_menu_form;
import 'package:order_management_demo/vertical_slices/create_restaurant/ui/create_restaurant_form.dart'
    deferred as _create_restaurant_form;
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/ui/kitchen_dashboard.dart'
    deferred as _kitchen_dashboard;
import 'package:order_management_demo/vertical_slices/order_view/ui/order_status_tracker.dart'
    deferred as _order_status_tracker;
import 'package:order_management_demo/vertical_slices/place_order/ui/place_order_form.dart'
    deferred as _place_order_form;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'theme_toggle': ClientLoader(
      (p) => _theme_toggle.ThemeToggle(),
      loader: _theme_toggle.loadLibrary,
    ),
    'change_menu_form': ClientLoader(
      (p) => _change_menu_form.ChangeMenuForm(
        initialRestaurants: (p['initialRestaurants'] as List<Object?>)
            .map((i) => (i as Map<String, Object?>).cast<String, String>())
            .toList(),
      ),
      loader: _change_menu_form.loadLibrary,
    ),
    'create_restaurant_form': ClientLoader(
      (p) => _create_restaurant_form.CreateRestaurantForm(),
      loader: _create_restaurant_form.loadLibrary,
    ),
    'kitchen_dashboard': ClientLoader(
      (p) => _kitchen_dashboard.KitchenDashboard(
        initialCreatedOrders: (p['initialCreatedOrders'] as List<Object?>)
            .map((i) => (i as Map<String, Object?>))
            .toList(),
        initialPreparedOrders: (p['initialPreparedOrders'] as List<Object?>)
            .map((i) => (i as Map<String, Object?>))
            .toList(),
      ),
      loader: _kitchen_dashboard.loadLibrary,
    ),
    'order_status_tracker': ClientLoader(
      (p) => _order_status_tracker.OrderStatusTracker(),
      loader: _order_status_tracker.loadLibrary,
    ),
    'place_order_form': ClientLoader(
      (p) => _place_order_form.PlaceOrderForm(
        initialRestaurants: (p['initialRestaurants'] as List<Object?>)
            .map((i) => (i as Map<String, Object?>).cast<String, String>())
            .toList(),
      ),
      loader: _place_order_form.loadLibrary,
    ),
  },
);
