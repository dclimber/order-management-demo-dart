import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../api.dart';
import '../dto.dart';
import '../state.dart';

Component orderLookupForm({String? orderId}) {
  return form(
    classes: 'lookup-form',
    attributes: {'method': 'get', 'action': '/order'},
    [
      label(attributes: {'for': 'order-id'}, [.text('Order ID')]),
      input(
        id: 'order-id',
        name: 'orderId',
        type: .text,
        attributes: orderId == null ? null : {'value': orderId},
      ),
      button(type: .submit, [.text('Track Order')]),
    ],
  );
}

Component orderViewCard(OrderViewState state, {bool showMarkLink = false}) {
  final statusClass = switch (state.status) {
    OrderStatus.prepared => 'status-badge prepared',
    OrderStatus.created => 'status-badge created',
  };

  return div(classes: 'data-card', [
    dl(classes: 'data-list', [
      div([
        dt([.text('Order ID')]),
        dd([.text(state.orderId.value)]),
      ]),
      div([
        dt([.text('Restaurant ID')]),
        dd([.text(state.restaurantId.value)]),
      ]),
      div([
        dt([.text('Status')]),
        dd([
          span(classes: statusClass, [.text(orderStatusLabel(state.status))]),
        ]),
      ]),
      div([
        dt([.text('Menu Items')]),
        dd([
          ul(classes: 'item-list', [
            for (final item in state.menuItems) li([.text('${item.name.value} — ${item.price.value}')]),
          ]),
        ]),
      ]),
    ]),
    if (showMarkLink)
      p(classes: 'text-muted', [
        .text('Mark as prepared from the '),
        a(href: '/kitchen', [.text('Kitchen')]),
        .text(' page.'),
      ]),
  ]);
}

Component orderListSection({
  required String title,
  required List<OrderViewState> orders,
  required String emptyMessage,
}) {
  return section(classes: 'order-section', [
    h2(classes: 'section-title', [.text(title)]),
    if (orders.isEmpty)
      p(classes: 'text-muted', [.text(emptyMessage)])
    else
      div(classes: 'card-list', [
        for (final order in orders) orderViewCard(order),
      ]),
  ]);
}
