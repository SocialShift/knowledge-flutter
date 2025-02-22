// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizNotifierHash() => r'1fe0e237fa626dd1457776f87fb04e06374f234c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$QuizNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<Quiz>> {
  late final String storyId;

  AsyncValue<Quiz> build(
    String storyId,
  );
}

/// See also [QuizNotifier].
@ProviderFor(QuizNotifier)
const quizNotifierProvider = QuizNotifierFamily();

/// See also [QuizNotifier].
class QuizNotifierFamily extends Family<AsyncValue<Quiz>> {
  /// See also [QuizNotifier].
  const QuizNotifierFamily();

  /// See also [QuizNotifier].
  QuizNotifierProvider call(
    String storyId,
  ) {
    return QuizNotifierProvider(
      storyId,
    );
  }

  @override
  QuizNotifierProvider getProviderOverride(
    covariant QuizNotifierProvider provider,
  ) {
    return call(
      provider.storyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quizNotifierProvider';
}

/// See also [QuizNotifier].
class QuizNotifierProvider
    extends AutoDisposeNotifierProviderImpl<QuizNotifier, AsyncValue<Quiz>> {
  /// See also [QuizNotifier].
  QuizNotifierProvider(
    String storyId,
  ) : this._internal(
          () => QuizNotifier()..storyId = storyId,
          from: quizNotifierProvider,
          name: r'quizNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$quizNotifierHash,
          dependencies: QuizNotifierFamily._dependencies,
          allTransitiveDependencies:
              QuizNotifierFamily._allTransitiveDependencies,
          storyId: storyId,
        );

  QuizNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storyId,
  }) : super.internal();

  final String storyId;

  @override
  AsyncValue<Quiz> runNotifierBuild(
    covariant QuizNotifier notifier,
  ) {
    return notifier.build(
      storyId,
    );
  }

  @override
  Override overrideWith(QuizNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuizNotifierProvider._internal(
        () => create()..storyId = storyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storyId: storyId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<QuizNotifier, AsyncValue<Quiz>>
      createElement() {
    return _QuizNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizNotifierProvider && other.storyId == storyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuizNotifierRef on AutoDisposeNotifierProviderRef<AsyncValue<Quiz>> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _QuizNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<QuizNotifier, AsyncValue<Quiz>>
    with QuizNotifierRef {
  _QuizNotifierProviderElement(super.provider);

  @override
  String get storyId => (origin as QuizNotifierProvider).storyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
