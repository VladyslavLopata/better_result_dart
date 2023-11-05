// ignore_for_file: inference_failure_on_function_invocation, inference_failure_on_instance_creation

import 'package:meta/meta.dart';
import 'package:result_dart/result_dart.dart';
import 'package:test/test.dart';

void main() {
  late MyUseCase useCase;

  setUpAll(() {
    useCase = MyUseCase();
  });

  group('factories', () {
    test('Success.unit', () {
      final result = Ok.unit();
      expect(result.getOrNull(), unit);
    });

    test('Success.unit type infer', () {
      Result<Unit, Exception> fn() {
        return Ok.unit();
      }

      final result = fn();
      expect(result.getOrNull(), unit);
    });

    test('Error.unit', () {
      final result = Err.unit();
      expect(result.errOrNull(), unit);
    });

    test('Error.unit type infer', () {
      Result<String, Unit> fn() {
        return Err.unit();
      }

      final result = fn();
      expect(result.errOrNull(), unit);
    });
  });

  test('Result.ok', () {
    const result = Result.ok(0);
    expect(result.getOrNull(), 0);
  });

  test('Result.err', () {
    const result = Result.err(0);
    expect(result.errOrNull(), 0);
  });

  test('''
Given a success result, 
        When getting the result through tryGetSuccess, 
        should return the success value''', () {
    final result = useCase();

    MyResult? successResult;
    if (result.isOk()) {
      successResult = result.getOrNull();
    }

    expect(successResult!.value, isA<String>());
    expect(result.isErr(), isFalse);
  });

  test('''
 Given an error result, 
          When getting the result through tryGetSuccess, 
          should return null ''', () {
    final result = useCase(returnError: true);

    MyResult? successResult;
    if (result.isOk()) {
      successResult = result.getOrNull();
    }

    expect(successResult?.value, null);
  });

  test('''
 Given an error result, 
  When getting the result through the tryGetError, 
  should return the error value
  ''', () {
    final result = useCase(returnError: true);

    MyException? exceptionResult;
    if (result.isErr()) {
      exceptionResult = result.errOrNull();
    }

    expect(exceptionResult != null, true);
    expect(result.isOk(), isFalse);
  });

  test('equatable', () {
    expect(const Ok(1) == const Ok(1), isTrue);
    expect(const Ok(1).hashCode == const Ok(1).hashCode, isTrue);

    expect(const Err(1) == const Err(1), isTrue);
    expect(const Err(1).hashCode == const Err(1).hashCode, isTrue);
  });

  group('MapError', () {
    test('Success', () {
      const result = Ok<int, int>(4);
      final result2 = result.mapError((error) => '=' * error);

      expect(result2.getOrNull(), 4);
      expect(result2.errOrNull(), isNull);
    });

    test('Error', () {
      const result = Err<String, int>(4);
      final result2 = result.mapError((error) => 'change');

      expect(result2.getOrNull(), isNull);
      expect(result2.errOrNull(), 'change');
    });
  });

  group('flatMap', () {
    test('Success', () {
      const result = Ok<int, int>(4);
      final result2 = result.flatMap((success) => Ok('=' * success));

      expect(result2.getOrNull(), '====');
    });

    test('Error', () {
      const result = Err<String, int>(4);
      final result2 = result.flatMap(Ok.new);

      expect(result2.getOrNull(), isNull);
      expect(result2.errOrNull(), 4);
    });
  });

  group('flatMapError', () {
    test('Error', () {
      const result = Err<int, int>(4);
      final result2 = result.flatMapError((error) => Err('=' * error));

      expect(result2.errOrNull(), '====');
    });

    test('Success', () {
      const result = Ok<int, String>(4);
      final result2 = result.flatMapError(Err.new);

      expect(result2.getOrNull(), 4);
      expect(result2.errOrNull(), isNull);
    });
  });

  group('pure', () {
    test('Success', () {
      final result = const Ok<int, int>(4) //
          .pure(6)
          .map((success) => '=' * success);

      expect(result.getOrNull(), '======');
    });

    test('Error', () {
      final result = const Err<String, int>(4).pure(6);

      expect(result.getOrNull(), isNull);
      expect(result.errOrNull(), 4);
    });
  });

  group('pureError', () {
    test('Error', () {
      final result = const Err<int, int>(4) //
          .pureError(6)
          .mapError((error) => '=' * error);

      expect(result.errOrNull(), '======');
    });

    test('Success', () {
      final result = const Ok<int, String>(4).pureError(6);

      expect(result.errOrNull(), isNull);
      expect(result.getOrNull(), 4);
    });
  });

  test('toAsyncResult', () {
    const result = Ok(0);

    // ignore: strict_raw_type
    expect(result.toAsyncResult(), isA<AsyncResult>());
  });

  group('swap', () {
    test('Success to Error', () {
      const result = Ok<int, String>(0);
      final swap = result.swap();

      expect(swap.errOrNull(), 0);
    });

    test('Error to Success', () {
      const result = Err<String, int>(0);
      final swap = result.swap();

      expect(swap.getOrNull(), 0);
    });
  });

  group('fold', () {
    test('Success', () {
      const result = Ok<int, String>(0);
      final futureValue = result.fold(identity, (e) => -1);
      expect(futureValue, 0);
    });

    test('Error', () {
      const result = Err<String, int>(0);
      final futureValue = result.fold((success) => -1, identity);
      expect(futureValue, 0);
    });
  });

  group('getOrElse', () {
    test('Success', () {
      const result = Ok<int, String>(0);
      final value = result.getOrElse((f) => -1);
      expect(value, 0);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.getOrElse((f) => 2);
      expect(value, 2);
    });
  });

  group('getOrDefault', () {
    test('Success', () {
      const result = Ok<int, String>(0);
      final value = result.getOrDefault(-1);
      expect(value, 0);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.getOrDefault(2);
      expect(value, 2);
    });
  });
}

Result<Unit, MyException> getMockedSuccessResult() {
  return Ok.unit();
}

class MyUseCase {
  Result<MyResult, MyException> call({bool returnError = false}) {
    if (returnError) {
      return const Err(MyException('something went wrong'));
    } else {
      return const Ok(MyResult('nice'));
    }
  }
}

@immutable
class MyException implements Exception {
  const MyException(this.message);

  final String message;

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) => //
      other is MyException && other.message == message;
}

@immutable
class MyResult {
  const MyResult(this.value);

  final String value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is MyResult && other.value == value;
}
