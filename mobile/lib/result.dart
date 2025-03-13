sealed class Result<T> {}

class Ok<T> implements Result<T> {
  final T data;

  const Ok(this.data);
}

class Err<T> implements Result<T> {
  final String message;

  const Err(this.message);
}
