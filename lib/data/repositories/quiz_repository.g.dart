// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizRepositoryHash() => r'4a223ab5ef56673db3af2da1d6d4ed4a773c2785';

/// See also [quizRepository].
@ProviderFor(quizRepository)
final quizRepositoryProvider = AutoDisposeProvider<QuizRepository>.internal(
  quizRepository,
  name: r'quizRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quizRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuizRepositoryRef = AutoDisposeProviderRef<QuizRepository>;
String _$storyQuizHash() => r'4dd2dcaee27560d210105c1c6642792b5bca2b35';

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

/// See also [storyQuiz].
@ProviderFor(storyQuiz)
const storyQuizProvider = StoryQuizFamily();

/// See also [storyQuiz].
class StoryQuizFamily extends Family<AsyncValue<Quiz?>> {
  /// See also [storyQuiz].
  const StoryQuizFamily();

  /// See also [storyQuiz].
  StoryQuizProvider call(
    String storyId,
  ) {
    return StoryQuizProvider(
      storyId,
    );
  }

  @override
  StoryQuizProvider getProviderOverride(
    covariant StoryQuizProvider provider,
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
  String? get name => r'storyQuizProvider';
}

/// See also [storyQuiz].
class StoryQuizProvider extends AutoDisposeFutureProvider<Quiz?> {
  /// See also [storyQuiz].
  StoryQuizProvider(
    String storyId,
  ) : this._internal(
          (ref) => storyQuiz(
            ref as StoryQuizRef,
            storyId,
          ),
          from: storyQuizProvider,
          name: r'storyQuizProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storyQuizHash,
          dependencies: StoryQuizFamily._dependencies,
          allTransitiveDependencies: StoryQuizFamily._allTransitiveDependencies,
          storyId: storyId,
        );

  StoryQuizProvider._internal(
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
  Override overrideWith(
    FutureOr<Quiz?> Function(StoryQuizRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoryQuizProvider._internal(
        (ref) => create(ref as StoryQuizRef),
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
  AutoDisposeFutureProviderElement<Quiz?> createElement() {
    return _StoryQuizProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryQuizProvider && other.storyId == storyId;
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
mixin StoryQuizRef on AutoDisposeFutureProviderRef<Quiz?> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _StoryQuizProviderElement extends AutoDisposeFutureProviderElement<Quiz?>
    with StoryQuizRef {
  _StoryQuizProviderElement(super.provider);

  @override
  String get storyId => (origin as StoryQuizProvider).storyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
