import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // Supabase singleton을 실제로 붙이지 않고, auth_provider 내부에서 사용하는
  // "구독을 invalidate로 연결할 AuthChangeEvent 집합" 자체를 검증한다.
  // 이 접근은 presentation layer의 Supabase static 의존성을 피하면서
  // 로직 변경을 RED→GREEN으로 포착한다.
  group('reactiveAuthEvents', () {
    test('should include signedOut (session expiry / remote sign-out)', () {
      expect(reactiveAuthEvents, contains(AuthChangeEvent.signedOut));
    });

    test('should include tokenRefreshed (session rotation)', () {
      expect(reactiveAuthEvents, contains(AuthChangeEvent.tokenRefreshed));
    });

    test('should include userUpdated (password change emit)', () {
      // Supabase gotrue는 비밀번호 변경 시 USER_UPDATED를 방송한다.
      // auth_provider는 이를 감지해 세션 상태를 재검증해야 한다.
      expect(reactiveAuthEvents, contains(AuthChangeEvent.userUpdated));
    });

    test(
      'should NOT react to events outside the reactive set '
      '(deprecated userDeleted, signedIn, etc.)',
      () {
        // gotrue 2.18 기준 AuthChangeEvent.userDeleted는 @Deprecated
        // 이고 jsName이 빈 문자열이라 서버가 방송하지 않는다. 명시적
        // 이름으로 참조하면 deprecated 린트가 뜨므로, "반응해야 하는
        // 이벤트는 정확히 signedOut/tokenRefreshed/userUpdated 3개"
        // 라는 더 강한 불변식으로 대체한다.
        expect(
          reactiveAuthEvents,
          equals(<AuthChangeEvent>{
            AuthChangeEvent.signedOut,
            AuthChangeEvent.tokenRefreshed,
            AuthChangeEvent.userUpdated,
          }),
        );
      },
    );

    test('should NOT include signedIn (build() already handles initial)', () {
      expect(reactiveAuthEvents, isNot(contains(AuthChangeEvent.signedIn)));
    });
  });
}
