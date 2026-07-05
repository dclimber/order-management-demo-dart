import '../../api.dart';

sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class RestaurantNotFoundError extends DomainError {
  RestaurantNotFoundError(this.restaurantId) : super('Restaurant $restaurantId does not exist');

  final RestaurantId restaurantId;
}