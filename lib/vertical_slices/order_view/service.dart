import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import '../../platform/event_store/event_store.dart';
import 'repository.dart';
import 'state.dart';
import 'view.dart';

/// Read-model queries for order projections (D4).
final class OrderViewService {
  OrderViewService({required EventStore eventStore}) : _eventStore = eventStore {
    repository = OrderEphemeralViewRepository(eventStore);
    ephemeralView = createEphemeralView(
      view: orderView,
      ephemeralViewRepository: repository,
    );
  }

  final EventStore _eventStore;
  late final OrderEphemeralViewRepository repository;
  late final EphemeralView<OrderViewState?, OrderEvent, OrderId> ephemeralView;

  Future<OrderViewState?> query(OrderId orderId) => ephemeralView.handle(orderId);

  Future<List<OrderId>> discoverIds() async {
    final ids = <OrderId>[];
    final seen = <String>{};
    await for (final event in _eventStore.streamByEventType('RestaurantOrderPlacedEvent')) {
      if (event case RestaurantOrderPlacedEvent(:final orderId)) {
        if (seen.add(orderId.value)) {
          ids.add(orderId);
        }
      }
    }
    return ids;
  }

  Future<List<OrderViewState>> listByStatus(OrderStatus status) async {
    final results = <OrderViewState>[];
    for (final orderId in await discoverIds()) {
      final view = await query(orderId);
      if (view?.status == status) {
        results.add(view!);
      }
    }
    return results;
  }
}
