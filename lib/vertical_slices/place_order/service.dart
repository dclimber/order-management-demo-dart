import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'repository.dart';

/// Write-side service: repository + aggregate built from [eventStore].
final class PlaceOrderService {
  PlaceOrderService({required EventStore eventStore}) {
    repository = PlaceOrderEventRepository(eventStore);
    aggregate = buildPlaceOrderAggregate(repository: repository);
  }

  late final PlaceOrderEventRepository repository;
  late final PlaceOrderAggregate aggregate;
}