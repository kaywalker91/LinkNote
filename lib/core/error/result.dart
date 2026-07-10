import 'package:linknote/core/error/failure.dart';

typedef Result<T> = ({T? data, Failure? failure});

extension ResultX<T> on Result<T> {
  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}

Result<T> success<T>(T data) => (data: data, failure: null);
Result<T> error<T>(Failure failure) => (data: null, failure: failure);
