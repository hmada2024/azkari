// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// يمثل خطأ حدث أثناء التعامل مع قاعدة البيانات.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// يمثل خطأ حدث أثناء التعامل مع الذاكرة المؤقتة (SharedPreferences).
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// يمثل خطأ غير متوقع أو عام.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
