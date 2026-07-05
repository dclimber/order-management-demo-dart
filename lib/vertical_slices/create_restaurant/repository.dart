import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';
import 'command.dart';

final class CreateRestaurantEventRepository
    with EventRepositoryDefaults<CreateRestaurantCommand, RestaurantEvent>
    implements EventRepository<CreateRestaurantCommand, RestaurantEvent, NoMetadata, NoMetadata> {
  CreateRestaurantEventRepository(this._store);

  final EventStore _store;

  @override
  Stream<RestaurantEvent> fetchEvents(CreateRestaurantCommand command) {
    return _store
        .streamFor(
          tag: 'restaurantId',
          value: command.restaurantId.value,
          eventTypes: [RestaurantCreatedEvent],
        )
        .cast<RestaurantEvent>();
  }

  @override
  Stream<RestaurantEvent> save(Stream<RestaurantEvent> events) {
    return _store.append(events).cast<RestaurantEvent>();
  }
}