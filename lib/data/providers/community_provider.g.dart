// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityCategoriesHash() =>
    r'ce226b0b59b28fa35334b16cd357fb20a20a4a83';

/// See also [communityCategories].
@ProviderFor(communityCategories)
final communityCategoriesProvider =
    AutoDisposeProvider<List<CommunityCategory>>.internal(
  communityCategories,
  name: r'communityCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communityCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityCategoriesRef
    = AutoDisposeProviderRef<List<CommunityCategory>>;
String _$allCommunitiesHash() => r'd991c3928bd59808326fd41bb7035e9b311a2aa7';

/// See also [allCommunities].
@ProviderFor(allCommunities)
final allCommunitiesProvider =
    AutoDisposeFutureProvider<List<Community>>.internal(
  allCommunities,
  name: r'allCommunitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCommunitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCommunitiesRef = AutoDisposeFutureProviderRef<List<Community>>;
String _$communitiesByCategoryHash() =>
    r'03598b98e95b00699d7f64602906478148057a0f';

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

/// See also [communitiesByCategory].
@ProviderFor(communitiesByCategory)
const communitiesByCategoryProvider = CommunitiesByCategoryFamily();

/// See also [communitiesByCategory].
class CommunitiesByCategoryFamily extends Family<AsyncValue<List<Community>>> {
  /// See also [communitiesByCategory].
  const CommunitiesByCategoryFamily();

  /// See also [communitiesByCategory].
  CommunitiesByCategoryProvider call(
    String categoryId,
  ) {
    return CommunitiesByCategoryProvider(
      categoryId,
    );
  }

  @override
  CommunitiesByCategoryProvider getProviderOverride(
    covariant CommunitiesByCategoryProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'communitiesByCategoryProvider';
}

/// See also [communitiesByCategory].
class CommunitiesByCategoryProvider
    extends AutoDisposeFutureProvider<List<Community>> {
  /// See also [communitiesByCategory].
  CommunitiesByCategoryProvider(
    String categoryId,
  ) : this._internal(
          (ref) => communitiesByCategory(
            ref as CommunitiesByCategoryRef,
            categoryId,
          ),
          from: communitiesByCategoryProvider,
          name: r'communitiesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$communitiesByCategoryHash,
          dependencies: CommunitiesByCategoryFamily._dependencies,
          allTransitiveDependencies:
              CommunitiesByCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CommunitiesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<List<Community>> Function(CommunitiesByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunitiesByCategoryProvider._internal(
        (ref) => create(ref as CommunitiesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Community>> createElement() {
    return _CommunitiesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunitiesByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunitiesByCategoryRef
    on AutoDisposeFutureProviderRef<List<Community>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CommunitiesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Community>>
    with CommunitiesByCategoryRef {
  _CommunitiesByCategoryProviderElement(super.provider);

  @override
  String get categoryId => (origin as CommunitiesByCategoryProvider).categoryId;
}

String _$joinedCommunitiesHash() => r'08933c7205532ec381d5e03cc0b7160615245f68';

/// See also [joinedCommunities].
@ProviderFor(joinedCommunities)
final joinedCommunitiesProvider =
    AutoDisposeFutureProvider<List<Community>>.internal(
  joinedCommunities,
  name: r'joinedCommunitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$joinedCommunitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JoinedCommunitiesRef = AutoDisposeFutureProviderRef<List<Community>>;
String _$communityActionsHash() => r'8789493cdb07e8569683b4a32e665b95d724c091';

/// See also [CommunityActions].
@ProviderFor(CommunityActions)
final communityActionsProvider =
    AutoDisposeNotifierProvider<CommunityActions, void>.internal(
  CommunityActions.new,
  name: r'communityActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communityActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CommunityActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
