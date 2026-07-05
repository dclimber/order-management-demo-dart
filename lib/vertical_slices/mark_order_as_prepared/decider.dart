import 'package:fmodel/fmodel.dart';

import '../../api.dart';
import 'command.dart';
import 'errors.dart';
import 'state.dart';

final markOrderAsPreparedDecider = Decider<MarkOrderAsPreparedCommand, MarkOrderAsPreparedState, OrderEvent>(
  initialState: const MarkOrderAsPreparedState(),
  decide: (command, state) async* {
    if (state.orderId == null) {
      throw OrderNotFoundError(command.orderId);
    }
    if (state.prepared) {
      throw OrderAlreadyPreparedError(command.orderId);
    }
    yield OrderPreparedEvent(orderId: command.orderId);
  },
  evolve: (state, event) => switch (event) {
    RestaurantOrderPlacedEvent(:final orderId) => MarkOrderAsPreparedState(
      orderId: orderId,
    ),
    OrderPreparedEvent() => state.copyWith(prepared: true),
  },
);