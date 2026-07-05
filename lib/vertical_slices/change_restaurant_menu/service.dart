import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'repository.dart';

/// Write-side service: repository + aggregate built from [eventStore].
final class ChangeRestaurantMenuService {
  ChangeRestaurantMenuService({required EventStore eventStore}) {
    repository = ChangeRestaurantMenuEventRepository(eventStore);
    aggregate = buildChangeRestaurantMenuAggregate(repository: repository);
  }

  late final ChangeRestaurantMenuEventRepository repository;
  late final ChangeRestaurantMenuAggregate aggregate;
}