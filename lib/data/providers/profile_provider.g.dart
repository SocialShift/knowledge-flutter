// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileHash() => r'311c92a8a5e148ab9d253d0c2baf581f7c397d7e';

/// See also [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeFutureProvider<Profile>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeFutureProviderRef<Profile>;
String _$profileNotifierHash() => r'c88f138d0e9bcce35f0f8a2312f911d3398df1e4';

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
final profileNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProfileNotifier, void>.internal(
  ProfileNotifier.new,
  name: r'profileNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
