// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tags_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userTags)
final userTagsProvider = UserTagsProvider._();

final class UserTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TagEntity>>,
          List<TagEntity>,
          FutureOr<List<TagEntity>>
        >
    with $FutureModifier<List<TagEntity>>, $FutureProvider<List<TagEntity>> {
  UserTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTagsHash();

  @$internal
  @override
  $FutureProviderElement<List<TagEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TagEntity>> create(Ref ref) {
    return userTags(ref);
  }
}

String _$userTagsHash() => r'08861769678cf8bd9ac3d89fb3e9178024cc8323';
