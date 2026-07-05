import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';
import 'repository.dart';
import 'state.dart';
import 'view.dart';

/// Read-model queries for restaurant projections (D4).
final class RestaurantViewService {
  RestaurantViewService({required EventStore eventStore}) : _eventStore = eventStore {
    repository = RestaurantEphemeralViewRepository(eventStore);
    ephemeralView = createEphemeralView(
      view: restaurantView,
      ephemeralViewRepository: repository,
    );
  }

  final EventStore _eventStore;
  late final RestaurantEphemeralViewRepository repository;
  late final EphemeralView<RestaurantViewState?, RestaurantEvent, RestaurantId> ephemeralView;

  Future<RestaurantViewState?> query(RestaurantId restaurantId) => ephemeralView.handle(restaurantId);

  Future<List<RestaurantId>> discoverIds() async {
    final ids = <RestaurantId>[];
    final seen = <String>{};
    await for (final event in _eventStore.streamByEventType('RestaurantCreatedEvent')) {
      if (event case RestaurantCreatedEvent(:final restaurantId)) {
        if (seen.add(restaurantId.value)) {
          ids.add(restaurantId);
        }
      }
    }
    return ids;
  }

  Future<List<RestaurantViewState>> queryAll() async {
    final results = <RestaurantViewState>[];
    for (final restaurantId in await discoverIds()) {
      final view = await query(restaurantId);
      if (view != null) {
        results.add(view);
      }
    }
    return results;
  }
}
