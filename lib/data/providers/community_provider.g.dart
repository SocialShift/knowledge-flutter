// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityCategoriesHash() =>
    r'4a0749b6b5d08517da46bb5df729227d9f576c31';

/// See also [communityCategories].
@ProviderFor(communityCategories)
final communityCategoriesProvider =
    AutoDisposeFutureProvider<List<CommunityCategory>>.internal(
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
    = AutoDisposeFutureProviderRef<List<CommunityCategory>>;
String _$allCommunitiesHash() => r'02753262d02264bc3cebd972add6f2b14ea9a204';

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
    r'edbc6244d9cb8c9f8fed5585dffbae2a5e7edc62';

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

String _$joinedCommunitiesHash() => r'81904c31d09c0dc2d0c48a8338ce8edacb031872';

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
String _$communityDetailsHash() => r'8b8574fa403050d7682469cb26d8f11e84f48651';

/// See also [communityDetails].
@ProviderFor(communityDetails)
const communityDetailsProvider = CommunityDetailsFamily();

/// See also [communityDetails].
class CommunityDetailsFamily extends Family<AsyncValue<Community>> {
  /// See also [communityDetails].
  const CommunityDetailsFamily();

  /// See also [communityDetails].
  CommunityDetailsProvider call(
    int communityId,
  ) {
    return CommunityDetailsProvider(
      communityId,
    );
  }

  @override
  CommunityDetailsProvider getProviderOverride(
    covariant CommunityDetailsProvider provider,
  ) {
    return call(
      provider.communityId,
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
  String? get name => r'communityDetailsProvider';
}

/// See also [communityDetails].
class CommunityDetailsProvider extends AutoDisposeFutureProvider<Community> {
  /// See also [communityDetails].
  CommunityDetailsProvider(
    int communityId,
  ) : this._internal(
          (ref) => communityDetails(
            ref as CommunityDetailsRef,
            communityId,
          ),
          from: communityDetailsProvider,
          name: r'communityDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$communityDetailsHash,
          dependencies: CommunityDetailsFamily._dependencies,
          allTransitiveDependencies:
              CommunityDetailsFamily._allTransitiveDependencies,
          communityId: communityId,
        );

  CommunityDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
  }) : super.internal();

  final int communityId;

  @override
  Override overrideWith(
    FutureOr<Community> Function(CommunityDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityDetailsProvider._internal(
        (ref) => create(ref as CommunityDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Community> createElement() {
    return _CommunityDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityDetailsProvider &&
        other.communityId == communityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityDetailsRef on AutoDisposeFutureProviderRef<Community> {
  /// The parameter `communityId` of this provider.
  int get communityId;
}

class _CommunityDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Community>
    with CommunityDetailsRef {
  _CommunityDetailsProviderElement(super.provider);

  @override
  int get communityId => (origin as CommunityDetailsProvider).communityId;
}

String _$joinCommunityActionHash() =>
    r'4cfa02c82b9e9283ec2e0ce3a4e6aca564e990c4';

/// See also [joinCommunityAction].
@ProviderFor(joinCommunityAction)
const joinCommunityActionProvider = JoinCommunityActionFamily();

/// See also [joinCommunityAction].
class JoinCommunityActionFamily extends Family<AsyncValue<void>> {
  /// See also [joinCommunityAction].
  const JoinCommunityActionFamily();

  /// See also [joinCommunityAction].
  JoinCommunityActionProvider call(
    int communityId,
  ) {
    return JoinCommunityActionProvider(
      communityId,
    );
  }

  @override
  JoinCommunityActionProvider getProviderOverride(
    covariant JoinCommunityActionProvider provider,
  ) {
    return call(
      provider.communityId,
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
  String? get name => r'joinCommunityActionProvider';
}

/// See also [joinCommunityAction].
class JoinCommunityActionProvider extends AutoDisposeFutureProvider<void> {
  /// See also [joinCommunityAction].
  JoinCommunityActionProvider(
    int communityId,
  ) : this._internal(
          (ref) => joinCommunityAction(
            ref as JoinCommunityActionRef,
            communityId,
          ),
          from: joinCommunityActionProvider,
          name: r'joinCommunityActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$joinCommunityActionHash,
          dependencies: JoinCommunityActionFamily._dependencies,
          allTransitiveDependencies:
              JoinCommunityActionFamily._allTransitiveDependencies,
          communityId: communityId,
        );

  JoinCommunityActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
  }) : super.internal();

  final int communityId;

  @override
  Override overrideWith(
    FutureOr<void> Function(JoinCommunityActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JoinCommunityActionProvider._internal(
        (ref) => create(ref as JoinCommunityActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _JoinCommunityActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinCommunityActionProvider &&
        other.communityId == communityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JoinCommunityActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `communityId` of this provider.
  int get communityId;
}

class _JoinCommunityActionProviderElement
    extends AutoDisposeFutureProviderElement<void> with JoinCommunityActionRef {
  _JoinCommunityActionProviderElement(super.provider);

  @override
  int get communityId => (origin as JoinCommunityActionProvider).communityId;
}

String _$leaveCommunityActionHash() =>
    r'bddf32a5cff008ba3b00f40e8f133b005cad7357';

/// See also [leaveCommunityAction].
@ProviderFor(leaveCommunityAction)
const leaveCommunityActionProvider = LeaveCommunityActionFamily();

/// See also [leaveCommunityAction].
class LeaveCommunityActionFamily extends Family<AsyncValue<void>> {
  /// See also [leaveCommunityAction].
  const LeaveCommunityActionFamily();

  /// See also [leaveCommunityAction].
  LeaveCommunityActionProvider call(
    int communityId,
  ) {
    return LeaveCommunityActionProvider(
      communityId,
    );
  }

  @override
  LeaveCommunityActionProvider getProviderOverride(
    covariant LeaveCommunityActionProvider provider,
  ) {
    return call(
      provider.communityId,
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
  String? get name => r'leaveCommunityActionProvider';
}

/// See also [leaveCommunityAction].
class LeaveCommunityActionProvider extends AutoDisposeFutureProvider<void> {
  /// See also [leaveCommunityAction].
  LeaveCommunityActionProvider(
    int communityId,
  ) : this._internal(
          (ref) => leaveCommunityAction(
            ref as LeaveCommunityActionRef,
            communityId,
          ),
          from: leaveCommunityActionProvider,
          name: r'leaveCommunityActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$leaveCommunityActionHash,
          dependencies: LeaveCommunityActionFamily._dependencies,
          allTransitiveDependencies:
              LeaveCommunityActionFamily._allTransitiveDependencies,
          communityId: communityId,
        );

  LeaveCommunityActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
  }) : super.internal();

  final int communityId;

  @override
  Override overrideWith(
    FutureOr<void> Function(LeaveCommunityActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeaveCommunityActionProvider._internal(
        (ref) => create(ref as LeaveCommunityActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _LeaveCommunityActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveCommunityActionProvider &&
        other.communityId == communityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LeaveCommunityActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `communityId` of this provider.
  int get communityId;
}

class _LeaveCommunityActionProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with LeaveCommunityActionRef {
  _LeaveCommunityActionProviderElement(super.provider);

  @override
  int get communityId => (origin as LeaveCommunityActionProvider).communityId;
}

String _$communityPostsHash() => r'85bf12a82952a091bd2896a0e78653d1497ac729';

/// See also [communityPosts].
@ProviderFor(communityPosts)
const communityPostsProvider = CommunityPostsFamily();

/// See also [communityPosts].
class CommunityPostsFamily extends Family<AsyncValue<List<Post>>> {
  /// See also [communityPosts].
  const CommunityPostsFamily();

  /// See also [communityPosts].
  CommunityPostsProvider call(
    int communityId,
  ) {
    return CommunityPostsProvider(
      communityId,
    );
  }

  @override
  CommunityPostsProvider getProviderOverride(
    covariant CommunityPostsProvider provider,
  ) {
    return call(
      provider.communityId,
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
  String? get name => r'communityPostsProvider';
}

/// See also [communityPosts].
class CommunityPostsProvider extends AutoDisposeFutureProvider<List<Post>> {
  /// See also [communityPosts].
  CommunityPostsProvider(
    int communityId,
  ) : this._internal(
          (ref) => communityPosts(
            ref as CommunityPostsRef,
            communityId,
          ),
          from: communityPostsProvider,
          name: r'communityPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$communityPostsHash,
          dependencies: CommunityPostsFamily._dependencies,
          allTransitiveDependencies:
              CommunityPostsFamily._allTransitiveDependencies,
          communityId: communityId,
        );

  CommunityPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
  }) : super.internal();

  final int communityId;

  @override
  Override overrideWith(
    FutureOr<List<Post>> Function(CommunityPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityPostsProvider._internal(
        (ref) => create(ref as CommunityPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Post>> createElement() {
    return _CommunityPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityPostsProvider && other.communityId == communityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityPostsRef on AutoDisposeFutureProviderRef<List<Post>> {
  /// The parameter `communityId` of this provider.
  int get communityId;
}

class _CommunityPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<Post>>
    with CommunityPostsRef {
  _CommunityPostsProviderElement(super.provider);

  @override
  int get communityId => (origin as CommunityPostsProvider).communityId;
}

String _$postCommentsHash() => r'e30f894914b28f705e4174362b7c445c2740f3db';

/// See also [postComments].
@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily();

/// See also [postComments].
class PostCommentsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [postComments].
  const PostCommentsFamily();

  /// See also [postComments].
  PostCommentsProvider call(
    int postId,
  ) {
    return PostCommentsProvider(
      postId,
    );
  }

  @override
  PostCommentsProvider getProviderOverride(
    covariant PostCommentsProvider provider,
  ) {
    return call(
      provider.postId,
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
  String? get name => r'postCommentsProvider';
}

/// See also [postComments].
class PostCommentsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [postComments].
  PostCommentsProvider(
    int postId,
  ) : this._internal(
          (ref) => postComments(
            ref as PostCommentsRef,
            postId,
          ),
          from: postCommentsProvider,
          name: r'postCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postCommentsHash,
          dependencies: PostCommentsFamily._dependencies,
          allTransitiveDependencies:
              PostCommentsFamily._allTransitiveDependencies,
          postId: postId,
        );

  PostCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PostCommentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsProvider._internal(
        (ref) => create(ref as PostCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PostCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCommentsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _PostCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PostCommentsRef {
  _PostCommentsProviderElement(super.provider);

  @override
  int get postId => (origin as PostCommentsProvider).postId;
}

String _$communityActionsHash() => r'dcb66e66a8af510d9f73f340ddb4e2e6a5825595';

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
String _$postActionsHash() => r'b6987950bcc8dc7b386fbae83256c0f55332fe59';

/// See also [PostActions].
@ProviderFor(PostActions)
final postActionsProvider =
    AutoDisposeNotifierProvider<PostActions, void>.internal(
  PostActions.new,
  name: r'postActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$postActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PostActions = AutoDisposeNotifier<void>;
String _$commentActionsHash() => r'704c97ec30e3f2a061673a423277de8198ecb9e4';

/// See also [CommentActions].
@ProviderFor(CommentActions)
final commentActionsProvider =
    AutoDisposeNotifierProvider<CommentActions, void>.internal(
  CommentActions.new,
  name: r'commentActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CommentActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
