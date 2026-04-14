// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkForm)
final linkFormProvider = LinkFormFamily._();

final class LinkFormProvider
    extends $AsyncNotifierProvider<LinkForm, LinkFormState> {
  LinkFormProvider._({
    required LinkFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'linkFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkFormHash();

  @override
  String toString() {
    return r'linkFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LinkForm create() => LinkForm();

  @override
  bool operator ==(Object other) {
    return other is LinkFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkFormHash() => r'46c71a1bc4e302ab253e14af76ad912a7fff3c9c';

final class LinkFormFamily extends $Family
    with
        $ClassFamilyOverride<
          LinkForm,
          AsyncValue<LinkFormState>,
          LinkFormState,
          FutureOr<LinkFormState>,
          String?
        > {
  LinkFormFamily._()
    : super(
        retry: null,
        name: r'linkFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LinkFormProvider call(String? linkId) =>
      LinkFormProvider._(argument: linkId, from: this);

  @override
  String toString() => r'linkFormProvider';
}

abstract class _$LinkForm extends $AsyncNotifier<LinkFormState> {
  late final _$args = ref.$arg as String?;
  String? get linkId => _$args;

  FutureOr<LinkFormState> build(String? linkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LinkFormState>, LinkFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LinkFormState>, LinkFormState>,
              AsyncValue<LinkFormState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
