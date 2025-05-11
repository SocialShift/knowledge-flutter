// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$socialRepositoryHash() => r'25f0a535906c2735370dad1105966e2704520a28';

/// See also [socialRepository].
@ProviderFor(socialRepository)
final socialRepositoryProvider = AutoDisposeProvider<SocialRepository>.internal(
  socialRepository,
  name: r'socialRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socialRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SocialRepositoryRef = AutoDisposeProviderRef<SocialRepository>;
String _$searchUsersHash() => r'ab7f6895bf00fea82fcdccba1a23324b244616a6';

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

/// See also [searchUsers].
@ProviderFor(searchUsers)
const searchUsersProvider = SearchUsersFamily();

/// See also [searchUsers].
class SearchUsersFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [searchUsers].
  const SearchUsersFamily();

  /// See also [searchUsers].
  SearchUsersProvider call(
    String query,
  ) {
    return SearchUsersProvider(
      query,
    );
  }

  @override
  SearchUsersProvider getProviderOverride(
    covariant SearchUsersProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchUsersProvider';
}

/// See also [searchUsers].
class SearchUsersProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [searchUsers].
  SearchUsersProvider(
    String query,
  ) : this._internal(
          (ref) => searchUsers(
            ref as SearchUsersRef,
            query,
          ),
          from: searchUsersProvider,
          name: r'searchUsersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchUsersHash,
          dependencies: SearchUsersFamily._dependencies,
          allTransitiveDependencies:
              SearchUsersFamily._allTransitiveDependencies,
          query: query,
        );

  SearchUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(SearchUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchUsersProvider._internal(
        (ref) => create(ref as SearchUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _SearchUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchUsersProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchUsersRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchUsersProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with SearchUsersRef {
  _SearchUsersProviderElement(super.provider);

  @override
  String get query => (origin as SearchUsersProvider).query;
}

String _$userProfileByIdHash() => r'5a914ab9df8f97d7f3d6bc99190d0d81215b1285';

/// See also [userProfileById].
@ProviderFor(userProfileById)
const userProfileByIdProvider = UserProfileByIdFamily();

/// See also [userProfileById].
class UserProfileByIdFamily extends Family<AsyncValue<Profile>> {
  /// See also [userProfileById].
  const UserProfileByIdFamily();

  /// See also [userProfileById].
  UserProfileByIdProvider call(
    int userId,
  ) {
    return UserProfileByIdProvider(
      userId,
    );
  }

  @override
  UserProfileByIdProvider getProviderOverride(
    covariant UserProfileByIdProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userProfileByIdProvider';
}

/// See also [userProfileById].
class UserProfileByIdProvider extends AutoDisposeFutureProvider<Profile> {
  /// See also [userProfileById].
  UserProfileByIdProvider(
    int userId,
  ) : this._internal(
          (ref) => userProfileById(
            ref as UserProfileByIdRef,
            userId,
          ),
          from: userProfileByIdProvider,
          name: r'userProfileByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProfileByIdHash,
          dependencies: UserProfileByIdFamily._dependencies,
          allTransitiveDependencies:
              UserProfileByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserProfileByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final int userId;

  @override
  Override overrideWith(
    FutureOr<Profile> Function(UserProfileByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileByIdProvider._internal(
        (ref) => create(ref as UserProfileByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Profile> createElement() {
    return _UserProfileByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileByIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileByIdRef on AutoDisposeFutureProviderRef<Profile> {
  /// The parameter `userId` of this provider.
  int get userId;
}

class _UserProfileByIdProviderElement
    extends AutoDisposeFutureProviderElement<Profile> with UserProfileByIdRef {
  _UserProfileByIdProviderElement(super.provider);

  @override
  int get userId => (origin as UserProfileByIdProvider).userId;
}

String _$followersHash() => r'd6c6ee0176583115a2a80b6535d7da79e905ce7a';

/// See also [followers].
@ProviderFor(followers)
const followersProvider = FollowersFamily();

/// See also [followers].
class FollowersFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [followers].
  const FollowersFamily();

  /// See also [followers].
  FollowersProvider call(
    int profileId,
  ) {
    return FollowersProvider(
      profileId,
    );
  }

  @override
  FollowersProvider getProviderOverride(
    covariant FollowersProvider provider,
  ) {
    return call(
      provider.profileId,
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
  String? get name => r'followersProvider';
}

/// See also [followers].
class FollowersProvider extends AutoDisposeFutureProvider<List<dynamic>> {
  /// See also [followers].
  FollowersProvider(
    int profileId,
  ) : this._internal(
          (ref) => followers(
            ref as FollowersRef,
            profileId,
          ),
          from: followersProvider,
          name: r'followersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$followersHash,
          dependencies: FollowersFamily._dependencies,
          allTransitiveDependencies: FollowersFamily._allTransitiveDependencies,
          profileId: profileId,
        );

  FollowersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final int profileId;

  @override
  Override overrideWith(
    FutureOr<List<dynamic>> Function(FollowersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FollowersProvider._internal(
        (ref) => create(ref as FollowersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<dynamic>> createElement() {
    return _FollowersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowersProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FollowersRef on AutoDisposeFutureProviderRef<List<dynamic>> {
  /// The parameter `profileId` of this provider.
  int get profileId;
}

class _FollowersProviderElement
    extends AutoDisposeFutureProviderElement<List<dynamic>> with FollowersRef {
  _FollowersProviderElement(super.provider);

  @override
  int get profileId => (origin as FollowersProvider).profileId;
}

String _$followingHash() => r'0f0ec8a2b4c3b29e3cbb31fc59934ed3e2f5e56d';

/// See also [following].
@ProviderFor(following)
const followingProvider = FollowingFamily();

/// See also [following].
class FollowingFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [following].
  const FollowingFamily();

  /// See also [following].
  FollowingProvider call(
    int profileId,
  ) {
    return FollowingProvider(
      profileId,
    );
  }

  @override
  FollowingProvider getProviderOverride(
    covariant FollowingProvider provider,
  ) {
    return call(
      provider.profileId,
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
  String? get name => r'followingProvider';
}

/// See also [following].
class FollowingProvider extends AutoDisposeFutureProvider<List<dynamic>> {
  /// See also [following].
  FollowingProvider(
    int profileId,
  ) : this._internal(
          (ref) => following(
            ref as FollowingRef,
            profileId,
          ),
          from: followingProvider,
          name: r'followingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$followingHash,
          dependencies: FollowingFamily._dependencies,
          allTransitiveDependencies: FollowingFamily._allTransitiveDependencies,
          profileId: profileId,
        );

  FollowingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final int profileId;

  @override
  Override overrideWith(
    FutureOr<List<dynamic>> Function(FollowingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FollowingProvider._internal(
        (ref) => create(ref as FollowingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<dynamic>> createElement() {
    return _FollowingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FollowingRef on AutoDisposeFutureProviderRef<List<dynamic>> {
  /// The parameter `profileId` of this provider.
  int get profileId;
}

class _FollowingProviderElement
    extends AutoDisposeFutureProviderElement<List<dynamic>> with FollowingRef {
  _FollowingProviderElement(super.provider);

  @override
  int get profileId => (origin as FollowingProvider).profileId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
