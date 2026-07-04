# LinkNote — Google Play Store 출시 실행 가이드 (v1.1.6)

**목표**: 최소 단계로 Internal Test까지 올리고, Production으로 안전하게 승격.

**최종 갱신**: 2026-07-04

## 0. 전제 조건 (이미 완료됨)
- ✅ Prod AAB 빌드 성공 (`flutter build appbundle --flavor prod --release`)
- ✅ 릴리스 서명 키 준비 (`android/linknote-release.keystore`)
- ✅ 스토어 리스팅 초안 (`docs/store-listing.md`)
- ✅ 개인정보처리방침 초안 (`docs/privacy-policy.md`)
- ✅ 스크린샷 5장 준비 (`docs/assets/`)
- ✅ Supabase prod + RLS 완료
- ✅ Firebase prod 설정 완료

**릴리스 키 (upload key) — Firebase 등록용**
```
SHA-1:  BE:28:55:35:00:F2:D6:FE:3E:8C:28:4D:4B:4D:12:EF:51:B5:63:C1
SHA-256: 3E:08:35:E4:C0:09:8A:EA:80:E8:25:10:06:7D:D4:12:86:9B:23:08:C2:88:F0:B9:88:9A:3F:DB:C4:D2:FB:92
```
(항상 `./gradlew signingReport`로 본인 환경에서 재확인)

---

## 1. 즉시 실행 단계 (우선순위 순)

### 1.1 피처 그래픽 제작 (필수, 30~60분)
- 규격: 1024 × 500 px (PNG 또는 JPG)
- 위치: `docs/assets/feature-graphic.png` 추천
- 생성된 후보: 세션 이미지 폴더 참조 (1.jpg 등)
- Play Console 업로드 시 "그래픽 자산 > 피처 그래픽"에 사용

### 1.2 개인정보처리방침 공개 (필수)
1. `docs/privacy-policy.md` 를 다음 중 하나에 게시:
   - GitHub Pages (프로젝트 `docs` 폴더 또는 별도 repo)
   - Notion 공개 페이지
   - 전용 도메인 (예: privacy.linknote.app)
2. 문의처 이메일 채우기 (현재 실제 문의처: `rikygak@gmail.com`)
3. URL을 메모해 두기 (Console 입력용)

### 1.3 Firebase SHA 등록 (필수)
1. Firebase Console → linknote-8994b 프로젝트
2. 프로젝트 설정 → Android 앱 (app.kaywalker.linknote) 선택
3. "SHA 인증서 지문 추가" 
4. 위 SHA-1 과 SHA-256 등록
5. (첫 AAB 업로드 후) Play Console → 앱 서명 → "앱 서명 인증서" SHA도 추가 등록 (강력 권장)

### 1.4 Google Play Console 준비
1. https://play.google.com/console 접속
2. $25 결제 + 개발자 계정 생성 (아직 안 했다면)
3. "앱 만들기" 
   - 앱 이름: LinkNote
   - 기본 언어: 한국어 (ko-KR)
   - 앱 패키지명: `app.kaywalker.linknote` (이미 등록되어 있으면 연결)
4. "앱 콘텐츠" 및 "스토어 등록정보" 섹션 채우기 시작

---

## 2. 스토어 등록정보 입력 (store-listing.md 복사해서 사용)

### 기본 정보
- 앱 이름: LinkNote
- 짧은 설명 (80자): `웹 링크·영상·메모를 한곳에 저장하고 태그·컬렉션·검색으로 정리하는 북마크 앱`

### 자세한 설명
`docs/store-listing.md`의 Full description 전체 복사.

### 그래픽 자산 업로드
- 앱 아이콘: 512×512 (이미 생성됨)
- 피처 그래픽: 1024×500 (1.1에서 제작한 것)
- 휴대폰 스크린샷: 5장 (`docs/assets/screenshot_*.png`)

### 앱 콘텐츠 (Data safety + 기타)
- 개인정보처리방침: 위에서 만든 공개 URL 입력
- Data safety: `docs/store-listing.md` 6.2 표 참고하여 정확히 응답
- 광고: 아니오
- 콘텐츠 등급: 설문 응답 (대부분 "없음" + 사용자 생성 콘텐츠 있음)
- 대상 연령층: 13세 이상

---

## 3. 빌드 & 업로드 명령어

```bash
# 1. 최종 릴리스 빌드
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 필요 시
flutter build appbundle --flavor prod --release

# 2. 생성된 파일 위치
build/app/outputs/bundle/prodRelease/app-prod-release.aab

# 3. (선택) 서명 빠른 확인
cd android
./gradlew signingReport | grep -A 6 "prodRelease"
```

**주의**: AAB를 직접 `apksigner`로 검증하려면 bundletool이 필요하지만, Play Console이 업로드 시 검증합니다.

---

## 4. 트랙 승격 전략 (권장)

1. **Internal test** (즉시)
   - 테스터: 본인 + 2~5명 (가족/친구)
   - 빠른 피드백 루프

2. **Closed test** (선택, 1주)
   - 더 많은 테스터 (이메일 리스트)

3. **Open test** (공개 베타)
   - "베타 테스터 찾기" 배너 노출

4. **Production** (정식 출시)
   - Staged rollout 시작 (5% 추천)
   - 모니터링 후 20% → 50% → 100%

각 단계마다 Play Console에서 "릴리스 노트" 업데이트 (CHANGELOG.md 내용 기반).

---

## 5. 실기기 QA 체크리스트 (업로드 전/후)

- [ ] prod flavor AAB 설치 (Internal test 또는 `adb install` 변환)
- [ ] 로그인 → Supabase prod 실제 데이터 로드
- [ ] 링크 저장 / 편집 / 삭제 / 즐겨찾기
- [ ] 검색 + 태그 필터
- [ ] 컬렉션 생성 → 공개 전환 → 딥링크 공유 (`linknote://collections/public/<id>`)
- [ ] 다른 계정으로 공개 컬렉션 읽기 전용 확인 (private 데이터 누출 없음)
- [ ] 읽기 통계 증가 확인 (링크 열기 → totalReads +1)
- [ ] 공유 인텐트 (다른 앱 → LinkNote로 URL 공유)
- [ ] Firebase DebugView에서 screen_view, first_open 수신 확인
- [ ] 강제 크래시 발생 → Crashlytics에 수신되는지 5~10분 후 확인

---

## 6. 출시 후 모니터링 (Phase 7.5)

- Crashlytics: 비정상 종료 즉시 확인
- Analytics: 주요 화면 전환, 세션 수
- Play Console 리뷰/평점 대응
- 버그 발견 시:
  1. fix 브랜치
  2. version bump (1.1.7+2 등)
  3. 새 AAB 업로드 → Production staged rollout

---

## 7. 치명적 주의사항

- **Keystore 분실 = 재앙**. `linknote-release.keystore` + 비밀번호를 최소 2곳 (암호화된 백업 + 오프라인 USB)에 보관.
- 첫 업로드 후 Google Play App Signing이 활성화되면, **Google이 관리하는 서명 키**가 실제 설치되는 키가 됩니다.
- Firebase에 upload key + Play App Signing key **둘 다** 등록하는 것이 가장 안전합니다.
- .env.prod 값이 prod 프로젝트를 정확히 가리키는지 출시 직전에 한 번 더 확인.

---

## 8. 남은 사용자 액션 체크리스트

- [ ] 피처 그래픽 제작 + 저장
- [ ] 개인정보처리방침 공개 URL 게시
- [ ] Play Console 개발자 등록 + 앱 생성
- [ ] Firebase SHA 등록 (릴리스 키)
- [ ] 스토어 등록정보 + Data safety 입력
- [ ] Internal test AAB 업로드 + 테스터 추가
- [ ] 실기기 QA 전체 수행
- [ ] Production rollout

문서 참조:
- `docs/release-checklist.md`
- `docs/store-listing.md`
- `docs/privacy-policy.md`

---

**준비 완료되면 "Internal test 업로드 도와줘" 또는 "다음 단계 진행"이라고 말해주세요.**
