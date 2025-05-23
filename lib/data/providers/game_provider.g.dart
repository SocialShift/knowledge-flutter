// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameQuestionsHash() => r'3ea19a1a07201ab8df0e4a5cd7615e49b569ef5d';

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

/// See also [gameQuestions].
@ProviderFor(gameQuestions)
const gameQuestionsProvider = GameQuestionsFamily();

/// See also [gameQuestions].
class GameQuestionsFamily extends Family<AsyncValue<List<GameQuestion>>> {
  /// See also [gameQuestions].
  const GameQuestionsFamily();

  /// See also [gameQuestions].
  GameQuestionsProvider call(
    int gameType,
  ) {
    return GameQuestionsProvider(
      gameType,
    );
  }

  @override
  GameQuestionsProvider getProviderOverride(
    covariant GameQuestionsProvider provider,
  ) {
    return call(
      provider.gameType,
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
  String? get name => r'gameQuestionsProvider';
}

/// See also [gameQuestions].
class GameQuestionsProvider
    extends AutoDisposeFutureProvider<List<GameQuestion>> {
  /// See also [gameQuestions].
  GameQuestionsProvider(
    int gameType,
  ) : this._internal(
          (ref) => gameQuestions(
            ref as GameQuestionsRef,
            gameType,
          ),
          from: gameQuestionsProvider,
          name: r'gameQuestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gameQuestionsHash,
          dependencies: GameQuestionsFamily._dependencies,
          allTransitiveDependencies:
              GameQuestionsFamily._allTransitiveDependencies,
          gameType: gameType,
        );

  GameQuestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameType,
  }) : super.internal();

  final int gameType;

  @override
  Override overrideWith(
    FutureOr<List<GameQuestion>> Function(GameQuestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameQuestionsProvider._internal(
        (ref) => create(ref as GameQuestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameType: gameType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GameQuestion>> createElement() {
    return _GameQuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameQuestionsProvider && other.gameType == gameType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameQuestionsRef on AutoDisposeFutureProviderRef<List<GameQuestion>> {
  /// The parameter `gameType` of this provider.
  int get gameType;
}

class _GameQuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<GameQuestion>>
    with GameQuestionsRef {
  _GameQuestionsProviderElement(super.provider);

  @override
  int get gameType => (origin as GameQuestionsProvider).gameType;
}

String _$gameStateNotifierHash() => r'1f23412ef96c92765477c2b1b1ceffaca516ee00';

/// See also [GameStateNotifier].
@ProviderFor(GameStateNotifier)
final gameStateNotifierProvider =
    AutoDisposeNotifierProvider<GameStateNotifier, GameState>.internal(
  GameStateNotifier.new,
  name: r'gameStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameStateNotifier = AutoDisposeNotifier<GameState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
