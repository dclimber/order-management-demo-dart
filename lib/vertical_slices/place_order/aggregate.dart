import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef PlaceOrderAggregate = EventSourcingAggregate<PlaceOrderCommand, PlaceOrderState, Event, NoMetadata, NoMetadata>;

PlaceOrderAggregate buildPlaceOrderAggregate({
  required PlaceOrderEventRepository repository,
}) {
  return createEventSourcingAggregate(
    decider: placeOrderDecider,
    eventRepository: repository,
  );
}