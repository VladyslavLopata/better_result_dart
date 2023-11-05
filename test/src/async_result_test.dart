// ignore_for_file: inference_failure_on_instance_creation

import 'package:result_dart/result_dart.dart';
import 'package:test/test.dart';

void main() {
  group('flatMap', () {
    test('async ', () async {
      final result = await const Ok(1) //
          .toAsyncResult()
          .flatMap((success) async => Ok(success * 2));
      expect(result.getOrNull(), 2);
    });

    test('sink', () async {
      final result = await const Ok(1) //
          .toAsyncResult()
          .flatMap((success) => Ok(success * 2));
      expect(result.getOrNull(), 2);
    });
  });

  group('flatMapError', () {
    test('async ', () async {
      final result = await const Err(1) //
          .toAsyncResult()
          .flatMapError((error) async => Err(error * 2));
      expect(result.errOrNull(), 2);
    });

    test('sink', () async {
      final result = await const Err(1) //
          .toAsyncResult()
          .flatMapError((error) => Err(error * 2));
      expect(result.errOrNull(), 2);
    });
  });

  test('map', () async {
    final result = await const Ok(1) //
        .toAsyncResult()
        .map((success) => success * 2);

    expect(result.getOrNull(), 2);
    expect(const Err(2).toAsyncResult().map(identity), completes);
  });

  test('mapError', () async {
    final result = await const Err(1) //
        .toAsyncResult()
        .mapError((error) => error * 2);
    expect(result.errOrNull(), 2);
    expect(const Ok(2).toAsyncResult().mapError(identity), completes);
  });

  test('pure', () async {
    final result = await const Ok(1).toAsyncResult().pure(10);

    expect(result.getOrNull(), 10);
  });
  test('pureError', () async {
    final result = await const Err(1).toAsyncResult().pureError(10);

    expect(result.errOrNull(), 10);
  });

  group('swap', () {
    test('Success to Error', () async {
      final result = const Ok<int, String>(0).toAsyncResult();
      final swap = await result.swap();

      expect(swap.errOrNull(), 0);
    });

    test('Error to Success', () async {
      final result = const Err<String, int>(0).toAsyncResult();
      final swap = await result.swap();

      expect(swap.getOrNull(), 0);
    });
  });

  group('fold', () {
    test('Success', () async {
      final result = const Ok<int, String>(0).toAsyncResult();
      final futureValue = result.fold(identity, (e) => -1);
      expect(futureValue, completion(0));
    });

    test('Error', () async {
      final result = const Err<String, int>(0).toAsyncResult();
      final futureValue = result.fold(identity, (e) => e);
      expect(futureValue, completion(0));
    });
  });

  group('tryGetSuccess and tryGetError', () {
    test('Success', () async {
      final result = const Ok<int, String>(0).toAsyncResult();

      expect(result.isSuccess(), completion(true));
      expect(result.getOrNull(), completion(0));
    });

    test('Error', () async {
      final result = const Err<String, int>(0).toAsyncResult();

      expect(result.isError(), completion(true));
      expect(result.exceptionOrNull(), completion(0));
    });
  });

  group('getOrElse', () {
    test('Success', () {
      final result = const Ok<int, String>(0).toAsyncResult();
      final value = result.getOrElse((f) => -1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = const Err<int, int>(0).toAsyncResult();
      final value = result.getOrElse((f) => 2);
      expect(value, completion(2));
    });
  });

  group('getOrDefault', () {
    test('Success', () {
      final result = const Ok<int, String>(0).toAsyncResult();
      final value = result.getOrDefault(-1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = const Err<int, int>(0).toAsyncResult();
      final value = result.getOrDefault(2);
      expect(value, completion(2));
    });
  });

  group('onSuccess', () {
    test('Success', () {
      const Ok<int, String>(0) //
          .toAsyncResult()
          .onFailure((failure) {})
          .onSuccess(
        expectAsync1(
          (value) {
            expect(value, 0);
          },
        ),
      );
    });

    test('Error', () {
      const Err<int, String>('failure') //
          .toAsyncResult()
          .onSuccess((success) {})
          .onFailure(
        expectAsync1(
          (value) {
            expect(value, 'failure');
          },
        ),
      );
    });
  });
}
