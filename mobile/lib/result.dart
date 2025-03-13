sealed class Result<T> {}

class Success<T> implements Result<T> {
  final T data;

  const Success(this.data);
}

class Error<T> implements Result<T> {
  final String message;

  const Error(this.message);
}
