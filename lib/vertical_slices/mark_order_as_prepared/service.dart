import '../../platform/event_store/event_store.dart';
import 'aggregate.dart';
import 'repository.dart';

/// Write-side service: repository + aggregate built from [eventStore].
final class MarkOrderAsPreparedService {
  MarkOrderAsPreparedService({required EventStore eventStore}) {
    repository = MarkOrderAsPreparedEventRepository(eventStore);
    aggregate = buildMarkOrderAsPreparedAggregate(repository: repository);
  }

  late final MarkOrderAsPreparedEventRepository repository;
  late final MarkOrderAsPreparedAggregate aggregate;
}