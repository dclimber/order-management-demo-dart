import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'decider.dart';
import 'repository.dart';
import 'state.dart';

typedef ChangeRestaurantMenuAggregate =
    EventSourcingAggregate<
      ChangeRestaurantMenuCommand,
      ChangeRestaurantMenuState,
      RestaurantEvent,
      NoMetadata,
      NoMetadata
    >;

ChangeRestaurantMenuAggregate buildChangeRestaurantMenuAggregate({
  required ChangeRestaurantMenuEventRepository repository,
}) {
  return createEventSourcingAggregate(
    decider: changeRestaurantMenuDecider,
    eventRepository: repository,
  );
}