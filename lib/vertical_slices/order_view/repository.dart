import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';

typedef OrderViewQuery = OrderId;

final class OrderEphemeralViewRepository implements EphemeralViewRepository<OrderEvent, OrderViewQuery> {
  OrderEphemeralViewRepository(this._store);

  final EventStore _store;

  @override
  Stream<OrderEvent> fetchEvents(OrderViewQuery query) {
    return _store.streamForQueries([
      (tag: 'orderId', value: query.value, eventType: RestaurantOrderPlacedEvent),
      (tag: 'orderId', value: query.value, eventType: OrderPreparedEvent),
    ]).cast<OrderEvent>();
  }
}
