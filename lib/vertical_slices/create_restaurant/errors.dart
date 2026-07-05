import '../../api.dart';

sealed class DomainError implements Exception {
  const DomainError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class RestaurantAlreadyExistsError extends DomainError {
  RestaurantAlreadyExistsError(this.restaurantId) : super('Restaurant $restaurantId already exists');

  final RestaurantId restaurantId;
}