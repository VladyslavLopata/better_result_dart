import 'package:meta/meta.dart';

import 'async_result.dart';
import 'unit.dart' as type_unit;

/// Base Result class
///
/// Receives two values [F] and [S]
/// as [F] is an error and [S] is a success.
sealed class Result<S, F> {
  /// Build a [Result] that returns a [Err].
  const factory Result.ok(S s) = Ok<S, F>;

  /// Build a [Result] that returns a [Err].
  const factory Result.err(F e) = Err<S, F>;

  /// Returns the encapsulated value if this instance represents `Success`
  /// or the result of `onFailure` function for
  /// the encapsulated a `Failure` value.
  S getOrElse(S Function(F failure) onFailure);

  /// Returns the encapsulated value if this instance represents
  /// `Success` or the `defaultValue` if it is `Failure`.
  S getOrDefault(S defaultValue);

  /// Returns the value of [Ok] or null.
  S? getOrNull();

  /// Returns the value of [Err] or null.
  F? errOrNull();

  /// Returns true if the current result is an [Err].
  bool isErr();

  /// Returns true if the current result is a [Ok].
  bool isOk();

  /// Returns the result of onSuccess for the encapsulated value
  /// if this instance represents `Success` or the result of onError function
  /// for the encapsulated value if it is `Failure`.
  W fold<W>(
    W Function(S success) onSuccess,
    W Function(F failure) onFailure,
  );

  /// Performs the given action on the encapsulated value if this
  /// instance represents success. Returns the original Result unchanged.
  Result<S, F> onSuccess(
    void Function(S success) onSuccess,
  );

  /// Performs the given action on the encapsulated Throwable
  /// exception if this instance represents failure.
  /// Returns the original Result unchanged.
  Result<S, F> onFailure(
    void Function(F failure) onFailure,
  );

  /// Returns a new `Result`, mapping any `Success` value
  /// using the given transformation.
  Result<W, F> map<W>(W Function(S success) fn);

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation.
  Result<S, W> mapError<W>(W Function(F error) fn);

  /// Returns a new `Result`, mapping any `Success` value
  /// using the given transformation and unwrapping the produced `Result`.
  Result<W, F> flatMap<W>(Result<W, F> Function(S success) fn);

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation and unwrapping the produced `Result`.
  Result<S, W> flatMapError<W>(
    Result<S, W> Function(F error) fn,
  );

  /// Change the [Ok] value.
  Result<W, F> pure<W>(W success);

  /// Change the [Err] value.
  Result<S, W> pureError<W>(W error);

  /// Return a [AsyncResult].
  AsyncResult<S, F> toAsyncResult();

  /// Swap the values contained inside the [Ok] and [Err]
  /// of this [Result].
  Result<F, S> swap();

  /// Returns the encapsulated `Result` of the given transform function
  /// applied to the encapsulated a `Failure` or the original
  /// encapsulated value if it is success.
  Result<S, R> recover<R>(
    Result<S, R> Function(F failure) onFailure,
  );

  /// Runs the callback provided within a try-catch block.
  /// If callback fails and error is caught, it is passed to [onError] callback.
  Result<S, F> tryCatch(
    S Function() callback,
    F Function(Object? error, StackTrace stackTrace) onError,
  );
}

/// Success Result.
///
/// return it when the result of a [Result] is
/// the expected value.
@immutable
final class Ok<S, F> implements Result<S, F> {
  /// Receives the [S] param as
  /// the successful result.
  const Ok(
    this._success,
  );

  /// Build a `Success` with `Unit` value.
  /// ```dart
  /// Success.unit() == Success(unit)
  /// ```
  static Ok<type_unit.Unit, F> unit<F>() {
    return Ok<type_unit.Unit, F>(type_unit.unit);
  }

  final S _success;

  @override
  bool isErr() => false;

  @override
  bool isOk() => true;

  @override
  int get hashCode => _success.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Ok && other._success == _success;
  }

  @override
  W fold<W>(
    W Function(S success) onSuccess,
    W Function(F error) onFailure,
  ) {
    return onSuccess(_success);
  }

  @override
  F? errOrNull() => null;

  @override
  S getOrNull() => _success;

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S success) fn) {
    return fn(_success);
  }

  @override
  Result<S, W> flatMapError<W>(
    Result<S, W> Function(F failure) fn,
  ) {
    return Ok<S, W>(_success);
  }

  @override
  Result<F, S> swap() {
    return Err(_success);
  }

  @override
  S getOrElse(S Function(F failure) onFailure) {
    return _success;
  }

  @override
  S getOrDefault(S defaultValue) => _success;

  @override
  Result<W, F> map<W>(W Function(S success) fn) {
    final newSuccess = fn(_success);
    return Ok<W, F>(newSuccess);
  }

  @override
  Result<S, W> mapError<W>(W Function(F error) fn) {
    return Ok<S, W>(_success);
  }

  @override
  Result<W, F> pure<W>(W success) {
    return map((_) => success);
  }

  @override
  Result<S, W> pureError<W>(W error) {
    return Ok<S, W>(_success);
  }

  @override
  Result<S, R> recover<R>(
    Result<S, R> Function(F failure) onFailure,
  ) {
    return Ok(_success);
  }

  @override
  AsyncResult<S, F> toAsyncResult() async => this;

  @override
  Result<S, F> onFailure(void Function(F failure) onFailure) {
    return this;
  }

  @override
  Result<S, F> onSuccess(void Function(S success) onSuccess) {
    onSuccess(_success);
    return this;
  }

  @override
  Result<S, F> tryCatch(
    S Function() callback,
    F Function(Object? error, StackTrace stackTrace) onError,
  ) {
    try {
      return Ok(callback());
    } catch (error, stackTrace) {
      return Err(onError(error, stackTrace));
    }
  }
}

/// Error Result.
///
/// return it when the result of a [Result] is
/// not the expected value.
@immutable
final class Err<S, F> implements Result<S, F> {
  /// Receives the [F] param as
  /// the error result.
  const Err(this._failure);

  /// Build a `Failure` with `Unit` value.
  /// ```dart
  /// Failure.unit() == Failure(unit)
  /// ```
  static Err<S, type_unit.Unit> unit<S>() {
    return Err<S, type_unit.Unit>(type_unit.unit);
  }

  final F _failure;

  @override
  bool isErr() => true;

  @override
  bool isOk() => false;

  @override
  int get hashCode => _failure.hashCode;

  @override
  bool operator ==(Object other) => //
      other is Err && other._failure == _failure;

  @override
  W fold<W>(
    W Function(S succcess) onSuccess,
    W Function(F failure) onFailure,
  ) {
    return onFailure(_failure);
  }

  @override
  F errOrNull() => _failure;

  @override
  S? getOrNull() => null;

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S success) fn) {
    return Err<W, F>(_failure);
  }

  @override
  Result<S, W> flatMapError<W>(
    Result<S, W> Function(F failure) fn,
  ) {
    return fn(_failure);
  }

  @override
  Result<F, S> swap() {
    return Ok(_failure);
  }

  // @override
  // S getOrThrow() {
  //   throw _failure;
  // }

  @override
  S getOrElse(S Function(F failure) onFailure) {
    return onFailure(_failure);
  }

  @override
  S getOrDefault(S defaultValue) => defaultValue;

  @override
  Result<W, F> map<W>(W Function(S success) fn) {
    return Err<W, F>(_failure);
  }

  @override
  Result<S, W> mapError<W>(W Function(F failure) fn) {
    final newFailure = fn(_failure);
    return Err(newFailure);
  }

  @override
  Result<W, F> pure<W>(W success) {
    return Err<W, F>(_failure);
  }

  @override
  Result<S, W> pureError<W>(W error) {
    return mapError((failure) => error);
  }

  @override
  Result<S, R> recover<R>(
    Result<S, R> Function(F failure) onFailure,
  ) {
    return onFailure(_failure);
  }

  @override
  AsyncResult<S, F> toAsyncResult() async => this;

  @override
  Result<S, F> onFailure(void Function(F failure) onFailure) {
    onFailure(_failure);
    return this;
  }

  @override
  Result<S, F> onSuccess(void Function(S success) onSuccess) {
    return this;
  }

  @override
  Result<S, F> tryCatch(
    S Function() callback,
    F Function(Object? error, StackTrace stackTrace) onError,
  ) {
    try {
      return Ok(callback());
    } catch (error, stackTrace) {
      return Err(onError(error, stackTrace));
    }
  }
}
