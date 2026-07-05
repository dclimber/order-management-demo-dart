sealed class HandlerResult<T> {
  const HandlerResult();
}

final class HandlerSuccess<T> extends HandlerResult<T> {
  const HandlerSuccess(this.value, {this.statusCode = 200});

  final T value;
  final int statusCode;
}

final class HandlerError extends HandlerResult<Never> {
  const HandlerError(this.statusCode, this.message);

  final int statusCode;
  final String message;
}
