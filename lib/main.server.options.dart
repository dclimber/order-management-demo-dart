// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:order_management_demo/shell/components/header.dart' as _header;
import 'package:order_management_demo/shell/components/theme_toggle.dart'
    as _theme_toggle;
import 'package:order_management_demo/shell/constants/theme.dart' as _theme;
import 'package:order_management_demo/shell/app.dart' as _app;
import 'package:order_management_demo/vertical_slices/change_restaurant_menu/ui/change_menu_form.dart'
    as _change_menu_form;
import 'package:order_management_demo/vertical_slices/create_restaurant/ui/create_restaurant_form.dart'
    as _create_restaurant_form;
import 'package:order_management_demo/vertical_slices/mark_order_as_prepared/ui/kitchen_dashboard.dart'
    as _kitchen_dashboard;
import 'package:order_management_demo/vertical_slices/order_view/ui/order_status_tracker.dart'
    as _order_status_tracker;
import 'package:order_management_demo/vertical_slices/place_order/ui/place_order_form.dart'
    as _place_order_form;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _theme_toggle.ThemeToggle: ClientTarget<_theme_toggle.ThemeToggle>(
      'theme_toggle',
    ),
    _change_menu_form.ChangeMenuForm:
        ClientTarget<_change_menu_form.ChangeMenuForm>(
          'change_menu_form',
          params: __change_menu_formChangeMenuForm,
        ),
    _create_restaurant_form.CreateRestaurantForm:
        ClientTarget<_create_restaurant_form.CreateRestaurantForm>(
          'create_restaurant_form',
        ),
    _kitchen_dashboard.KitchenDashboard:
        ClientTarget<_kitchen_dashboard.KitchenDashboard>(
          'kitchen_dashboard',
          params: __kitchen_dashboardKitchenDashboard,
        ),
    _order_status_tracker.OrderStatusTracker:
        ClientTarget<_order_status_tracker.OrderStatusTracker>(
          'order_status_tracker',
        ),
    _place_order_form.PlaceOrderForm:
        ClientTarget<_place_order_form.PlaceOrderForm>(
          'place_order_form',
          params: __place_order_formPlaceOrderForm,
        ),
  },
  styles: () => [
    ..._theme.styles,
    ..._app.App.styles,
    ..._header.Header.styles,
    ..._theme_toggle.ThemeToggle.styles,
  ],
);

Map<String, Object?> __change_menu_formChangeMenuForm(
  _change_menu_form.ChangeMenuForm c,
) => {'initialRestaurants': c.initialRestaurants};
Map<String, Object?> __kitchen_dashboardKitchenDashboard(
  _kitchen_dashboard.KitchenDashboard c,
) => {
  'initialCreatedOrders': c.initialCreatedOrders,
  'initialPreparedOrders': c.initialPreparedOrders,
};
Map<String, Object?> __place_order_formPlaceOrderForm(
  _place_order_form.PlaceOrderForm c,
) => {'initialRestaurants': c.initialRestaurants};
