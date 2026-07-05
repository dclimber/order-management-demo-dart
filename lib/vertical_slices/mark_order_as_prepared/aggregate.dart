import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef MarkOrderAsPreparedAggregate =
    EventSourcingAggregate<MarkOrderAsPreparedCommand, MarkOrderAsPreparedState, OrderEvent, NoMetadata, NoMetadata>;

MarkOrderAsPreparedAggregate buildMarkOrderAsPreparedAggregate({
  required MarkOrderAsPreparedEventRepository repository,
}) {
  return createEventSourcingAggregate(
    decider: markOrderAsPreparedDecider,
    eventRepository: repository,
  );
}