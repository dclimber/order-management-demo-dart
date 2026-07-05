import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef CreateRestaurantAggregate =
    EventSourcingAggregate<CreateRestaurantCommand, CreateRestaurantState, RestaurantEvent, NoMetadata, NoMetadata>;

CreateRestaurantAggregate buildCreateRestaurantAggregate({
  required CreateRestaurantEventRepository repository,
}) {
  return createEventSourcingAggregate(
    decider: createRestaurantDecider,
    eventRepository: repository,
  );
}