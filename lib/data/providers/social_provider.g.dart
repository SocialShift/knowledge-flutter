// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$socialNotifierHash() => r'6a05d65234e188cb0db43c8d7dcb877a82842827';

/// See also [SocialNotifier].
@ProviderFor(SocialNotifier)
final socialNotifierProvider = AutoDisposeNotifierProvider<SocialNotifier,
    AsyncValue<List<SocialUser>>>.internal(
  SocialNotifier.new,
  name: r'socialNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$socialNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SocialNotifier = AutoDisposeNotifier<AsyncValue<List<SocialUser>>>;
String _$searchQueryHash() => r'4a81f4981a852377cacaaef0daea5da3374edbaf';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
