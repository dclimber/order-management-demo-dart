import '../../api.dart';

final class MarkOrderAsPreparedState {
  const MarkOrderAsPreparedState({
    this.orderId,
    this.prepared = false,
  });

  final OrderId? orderId;
  final bool prepared;

  MarkOrderAsPreparedState copyWith({
    OrderId? orderId,
    bool? prepared,
  }) => MarkOrderAsPreparedState(
    orderId: orderId ?? this.orderId,
    prepared: prepared ?? this.prepared,
  );
}