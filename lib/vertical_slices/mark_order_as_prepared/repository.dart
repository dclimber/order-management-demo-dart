import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

final class MarkOrderAsPreparedEventRepository
    with EventRepositoryDefaults<MarkOrderAsPreparedCommand, OrderEvent>
    implements EventRepository<MarkOrderAsPreparedCommand, OrderEvent, NoMetadata, NoMetadata> {
  MarkOrderAsPreparedEventRepository(this._store);

  final EventStore _store;

  @override
  Stream<OrderEvent> fetchEvents(MarkOrderAsPreparedCommand command) {
    return _store.streamForQueries([
      (
        tag: 'orderId',
        value: command.orderId.value,
        eventType: RestaurantOrderPlacedEvent,
      ),
      (
        tag: 'orderId',
        value: command.orderId.value,
        eventType: OrderPreparedEvent,
      ),
    ]).cast<OrderEvent>();
  }

  @override
  Stream<OrderEvent> save(Stream<OrderEvent> events) {
    return _store.append(events).cast<OrderEvent>();
  }
}