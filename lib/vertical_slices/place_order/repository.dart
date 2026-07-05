import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

/// Cross-boundary repository: fetches [RestaurantEvent] history and persists [Event].
final class PlaceOrderEventRepository
    with EventRepositoryDefaults<PlaceOrderCommand, Event>
    implements EventRepository<PlaceOrderCommand, Event, NoMetadata, NoMetadata> {
  PlaceOrderEventRepository(this._store);

  final EventStore _store;

  @override
  Stream<Event> fetchEvents(PlaceOrderCommand command) {
    return _store.streamForQueries([
      (
        tag: 'restaurantId',
        value: command.restaurantId.value,
        eventType: RestaurantCreatedEvent,
      ),
      (
        tag: 'restaurantId',
        value: command.restaurantId.value,
        eventType: RestaurantMenuChangedEvent,
      ),
      (
        tag: 'orderId',
        value: command.orderId.value,
        eventType: RestaurantOrderPlacedEvent,
      ),
    ]);
  }

  @override
  Stream<Event> save(Stream<Event> events) => _store.append(events);
}