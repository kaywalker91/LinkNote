import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/profile/data/dto/user_profile_dto.dart';
import 'package:linknote/features/profile/data/mapper/profile_mapper.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';

void main() {
  group('ProfileMapper', () {
    const tDto = UserProfileDto(
      id: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      avatarUrl: 'https://example.com/avatar.png',
      linkCount: 5,
      collectionCount: 2,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-02T00:00:00Z',
    );

    const tEntity = UserProfileEntity(
      id: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      avatarUrl: 'https://example.com/avatar.png',
      linkCount: 5,
      collectionCount: 2,
    );

    test('should convert UserProfileDto to UserProfileEntity', () {
      final result = ProfileMapper.toEntity(tDto);

      expect(result, equals(tEntity));
    });

    test('should handle nullable fields correctly', () {
      const dtoWithNulls = UserProfileDto(
        id: 'user-456',
        email: 'null@example.com',
      );

      final result = ProfileMapper.toEntity(dtoWithNulls);

      expect(result.id, 'user-456');
      expect(result.email, 'null@example.com');
      expect(result.displayName, isNull);
      expect(result.avatarUrl, isNull);
      expect(result.linkCount, 0);
      expect(result.collectionCount, 0);
    });

    test('should convert entity to update JSON', () {
      final json = ProfileMapper.toUpdateJson(
        displayName: 'New Name',
        avatarUrl: 'https://example.com/new.png',
      );

      expect(json['display_name'], 'New Name');
      expect(json['avatar_url'], 'https://example.com/new.png');
      expect(json.containsKey('updated_at'), isTrue);
    });

    test('should exclude null fields from update JSON', () {
      final json = ProfileMapper.toUpdateJson(displayName: 'New Name');

      expect(json['display_name'], 'New Name');
      expect(json.containsKey('avatar_url'), isFalse);
    });
  });
}
