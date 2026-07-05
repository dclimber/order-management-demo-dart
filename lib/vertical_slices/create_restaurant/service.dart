import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'repository.dart';

/// Write-side service: repository + aggregate built from [eventStore].
final class CreateRestaurantService {
  CreateRestaurantService({required EventStore eventStore}) {
    repository = CreateRestaurantEventRepository(eventStore);
    aggregate = buildCreateRestaurantAggregate(repository: repository);
  }

  late final CreateRestaurantEventRepository repository;
  late final CreateRestaurantAggregate aggregate;
}