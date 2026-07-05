import '../../api.dart';

sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class OrderNotFoundError extends DomainError {
  OrderNotFoundError(this.orderId) : super('Order $orderId does not exist');

  final OrderId orderId;
}

final class OrderAlreadyPreparedError extends DomainError {
  OrderAlreadyPreparedError(this.orderId) : super('Order $orderId is already prepared');

  final OrderId orderId;
}