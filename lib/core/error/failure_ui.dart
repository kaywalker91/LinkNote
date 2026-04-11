import 'package:flutter/material.dart';
import 'package:linknote/core/error/failure.dart';

class FailureUi {
  const FailureUi({
    required this.title,
    required this.message,
    required this.icon,
    this.isRetryable = true,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isRetryable;
}

extension FailureUiX on Failure {
  FailureUi toUi() => switch (this) {
    NetworkFailure() => const FailureUi(
      title: '네트워크 오류',
      message: '인터넷 연결을 확인해 주세요.',
      icon: Icons.wifi_off_rounded,
    ),
    ServerFailure() => const FailureUi(
      title: '서버 오류',
      message: '잠시 후 다시 시도해 주세요.',
      icon: Icons.cloud_off_rounded,
    ),
    AuthFailure() => const FailureUi(
      title: '인증 오류',
      message: '다시 로그인해 주세요.',
      icon: Icons.lock_outline_rounded,
      isRetryable: false,
    ),
    CacheFailure() => const FailureUi(
      title: '데이터 오류',
      message: '앱을 다시 시작해 주세요.',
      icon: Icons.storage_rounded,
    ),
    UnknownFailure() => const FailureUi(
      title: '오류가 발생했습니다',
      message: '잠시 후 다시 시도해 주세요.',
      icon: Icons.error_outline_rounded,
    ),
  };
}

FailureUi failureUiFromError(Object error) {
  if (error is Failure) return error.toUi();
  return const FailureUi(
    title: '오류가 발생했습니다',
    message: '잠시 후 다시 시도해 주세요.',
    icon: Icons.error_outline_rounded,
  );
}
