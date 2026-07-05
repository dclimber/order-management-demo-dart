import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../api.dart';
import '../../composition/app_context.dart';
import '../../vertical_slices/order_view/ui/ui.dart';
import '../../vertical_slices/place_order/ui/ui.dart';
import '../../vertical_slices/restaurant_view/ui/ui.dart';

class OrderPage extends AsyncStatelessComponent {
  const OrderPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final query = RouteState.of(context).queryParams;
    final orderIdParam = query['orderId']?.trim();
    final restaurants = await appServices.queryAllRestaurants();
    final lookupResult = orderIdParam != null && orderIdParam.isNotEmpty ? await _buildOrderResult(orderIdParam) : null;

    return div(classes: 'page-container', [
      h1(classes: 'page-title', [.text('Order Management')]),
      PlaceOrderForm(initialRestaurants: restaurantSummaries(restaurants)),
      hr(classes: 'section-divider'),
      const OrderStatusTracker(),
      hr(classes: 'section-divider'),
      section(classes: 'page-section', [
        h2(classes: 'section-title', [.text('View Order (SSR)')]),
        orderLookupForm(orderId: orderIdParam),
        if (lookupResult != null) lookupResult,
      ]),
    ]);
  }

  Future<Component> _buildOrderResult(String orderIdParam) async {
    try {
      final state = await appServices.queryOrder(OrderId(orderIdParam));
      if (state == null) {
        return p(classes: 'error-message', [
          .text('Order $orderIdParam does not exist'),
        ]);
      }
      return orderViewCard(state, showMarkLink: true);
    } on ArgumentError catch (error) {
      return p(classes: 'error-message', [.text(error.message ?? 'Invalid order ID')]);
    }
  }
}
