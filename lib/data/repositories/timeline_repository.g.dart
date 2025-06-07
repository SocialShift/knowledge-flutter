// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineRepositoryHash() =>
    r'd2f83b65e3cfe6140f29b333b718360e66f46c04';

/// See also [timelineRepository].
@ProviderFor(timelineRepository)
final timelineRepositoryProvider =
    AutoDisposeProvider<TimelineRepository>.internal(
  timelineRepository,
  name: r'timelineRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timelineRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimelineRepositoryRef = AutoDisposeProviderRef<TimelineRepository>;
String _$timelinesHash() => r'af12e7912c446dbdc9f572c50b8f03ade1a36ebe';

/// See also [timelines].
@ProviderFor(timelines)
final timelinesProvider = AutoDisposeFutureProvider<List<Timeline>>.internal(
  timelines,
  name: r'timelinesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$timelinesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimelinesRef = AutoDisposeFutureProviderRef<List<Timeline>>;
String _$timelinesSortedByYearHash() =>
    r'93fb4d59c079ab5c909dee8256625c55348eec17';

/// See also [timelinesSortedByYear].
@ProviderFor(timelinesSortedByYear)
final timelinesSortedByYearProvider =
    AutoDisposeFutureProvider<List<Timeline>>.internal(
  timelinesSortedByYear,
  name: r'timelinesSortedByYearProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timelinesSortedByYearHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimelinesSortedByYearRef = AutoDisposeFutureProviderRef<List<Timeline>>;
String _$timelineDetailHash() => r'cc8d71bd60467753c5deb21a3a73db71d1c73908';

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

/// See also [timelineDetail].
@ProviderFor(timelineDetail)
const timelineDetailProvider = TimelineDetailFamily();

/// See also [timelineDetail].
class TimelineDetailFamily extends Family<AsyncValue<Timeline>> {
  /// See also [timelineDetail].
  const TimelineDetailFamily();

  /// See also [timelineDetail].
  TimelineDetailProvider call(
    String timelineId,
  ) {
    return TimelineDetailProvider(
      timelineId,
    );
  }

  @override
  TimelineDetailProvider getProviderOverride(
    covariant TimelineDetailProvider provider,
  ) {
    return call(
      provider.timelineId,
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
  String? get name => r'timelineDetailProvider';
}

/// See also [timelineDetail].
class TimelineDetailProvider extends AutoDisposeFutureProvider<Timeline> {
  /// See also [timelineDetail].
  TimelineDetailProvider(
    String timelineId,
  ) : this._internal(
          (ref) => timelineDetail(
            ref as TimelineDetailRef,
            timelineId,
          ),
          from: timelineDetailProvider,
          name: r'timelineDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timelineDetailHash,
          dependencies: TimelineDetailFamily._dependencies,
          allTransitiveDependencies:
              TimelineDetailFamily._allTransitiveDependencies,
          timelineId: timelineId,
        );

  TimelineDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.timelineId,
  }) : super.internal();

  final String timelineId;

  @override
  Override overrideWith(
    FutureOr<Timeline> Function(TimelineDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimelineDetailProvider._internal(
        (ref) => create(ref as TimelineDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        timelineId: timelineId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Timeline> createElement() {
    return _TimelineDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineDetailProvider && other.timelineId == timelineId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, timelineId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimelineDetailRef on AutoDisposeFutureProviderRef<Timeline> {
  /// The parameter `timelineId` of this provider.
  String get timelineId;
}

class _TimelineDetailProviderElement
    extends AutoDisposeFutureProviderElement<Timeline> with TimelineDetailRef {
  _TimelineDetailProviderElement(super.provider);

  @override
  String get timelineId => (origin as TimelineDetailProvider).timelineId;
}

String _$timelineStoriesHash() => r'00a139a002d19ede74d91c7ab6185fc38562fad4';

/// See also [timelineStories].
@ProviderFor(timelineStories)
const timelineStoriesProvider = TimelineStoriesFamily();

/// See also [timelineStories].
class TimelineStoriesFamily extends Family<AsyncValue<List<Story>>> {
  /// See also [timelineStories].
  const TimelineStoriesFamily();

  /// See also [timelineStories].
  TimelineStoriesProvider call(
    String timelineId,
  ) {
    return TimelineStoriesProvider(
      timelineId,
    );
  }

  @override
  TimelineStoriesProvider getProviderOverride(
    covariant TimelineStoriesProvider provider,
  ) {
    return call(
      provider.timelineId,
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
  String? get name => r'timelineStoriesProvider';
}

/// See also [timelineStories].
class TimelineStoriesProvider extends AutoDisposeFutureProvider<List<Story>> {
  /// See also [timelineStories].
  TimelineStoriesProvider(
    String timelineId,
  ) : this._internal(
          (ref) => timelineStories(
            ref as TimelineStoriesRef,
            timelineId,
          ),
          from: timelineStoriesProvider,
          name: r'timelineStoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timelineStoriesHash,
          dependencies: TimelineStoriesFamily._dependencies,
          allTransitiveDependencies:
              TimelineStoriesFamily._allTransitiveDependencies,
          timelineId: timelineId,
        );

  TimelineStoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.timelineId,
  }) : super.internal();

  final String timelineId;

  @override
  Override overrideWith(
    FutureOr<List<Story>> Function(TimelineStoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimelineStoriesProvider._internal(
        (ref) => create(ref as TimelineStoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        timelineId: timelineId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Story>> createElement() {
    return _TimelineStoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineStoriesProvider && other.timelineId == timelineId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, timelineId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimelineStoriesRef on AutoDisposeFutureProviderRef<List<Story>> {
  /// The parameter `timelineId` of this provider.
  String get timelineId;
}

class _TimelineStoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<Story>>
    with TimelineStoriesRef {
  _TimelineStoriesProviderElement(super.provider);

  @override
  String get timelineId => (origin as TimelineStoriesProvider).timelineId;
}

String _$storyDetailHash() => r'518caeff85fff5a406cc25a5358d86545ed6c4ed';

/// See also [storyDetail].
@ProviderFor(storyDetail)
const storyDetailProvider = StoryDetailFamily();

/// See also [storyDetail].
class StoryDetailFamily extends Family<AsyncValue<Story>> {
  /// See also [storyDetail].
  const StoryDetailFamily();

  /// See also [storyDetail].
  StoryDetailProvider call(
    String storyId,
  ) {
    return StoryDetailProvider(
      storyId,
    );
  }

  @override
  StoryDetailProvider getProviderOverride(
    covariant StoryDetailProvider provider,
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
  String? get name => r'storyDetailProvider';
}

/// See also [storyDetail].
class StoryDetailProvider extends AutoDisposeFutureProvider<Story> {
  /// See also [storyDetail].
  StoryDetailProvider(
    String storyId,
  ) : this._internal(
          (ref) => storyDetail(
            ref as StoryDetailRef,
            storyId,
          ),
          from: storyDetailProvider,
          name: r'storyDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$storyDetailHash,
          dependencies: StoryDetailFamily._dependencies,
          allTransitiveDependencies:
              StoryDetailFamily._allTransitiveDependencies,
          storyId: storyId,
        );

  StoryDetailProvider._internal(
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
    FutureOr<Story> Function(StoryDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoryDetailProvider._internal(
        (ref) => create(ref as StoryDetailRef),
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
  AutoDisposeFutureProviderElement<Story> createElement() {
    return _StoryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryDetailProvider && other.storyId == storyId;
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
mixin StoryDetailRef on AutoDisposeFutureProviderRef<Story> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _StoryDetailProviderElement
    extends AutoDisposeFutureProviderElement<Story> with StoryDetailRef {
  _StoryDetailProviderElement(super.provider);

  @override
  String get storyId => (origin as StoryDetailProvider).storyId;
}

String _$markStoryAsSeenHash() => r'49b3aac0eae80b7e5ff4e0ff5d8d0165b5c13614';

/// See also [markStoryAsSeen].
@ProviderFor(markStoryAsSeen)
const markStoryAsSeenProvider = MarkStoryAsSeenFamily();

/// See also [markStoryAsSeen].
class MarkStoryAsSeenFamily extends Family<AsyncValue<bool>> {
  /// See also [markStoryAsSeen].
  const MarkStoryAsSeenFamily();

  /// See also [markStoryAsSeen].
  MarkStoryAsSeenProvider call(
    String storyId,
  ) {
    return MarkStoryAsSeenProvider(
      storyId,
    );
  }

  @override
  MarkStoryAsSeenProvider getProviderOverride(
    covariant MarkStoryAsSeenProvider provider,
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
  String? get name => r'markStoryAsSeenProvider';
}

/// See also [markStoryAsSeen].
class MarkStoryAsSeenProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [markStoryAsSeen].
  MarkStoryAsSeenProvider(
    String storyId,
  ) : this._internal(
          (ref) => markStoryAsSeen(
            ref as MarkStoryAsSeenRef,
            storyId,
          ),
          from: markStoryAsSeenProvider,
          name: r'markStoryAsSeenProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markStoryAsSeenHash,
          dependencies: MarkStoryAsSeenFamily._dependencies,
          allTransitiveDependencies:
              MarkStoryAsSeenFamily._allTransitiveDependencies,
          storyId: storyId,
        );

  MarkStoryAsSeenProvider._internal(
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
    FutureOr<bool> Function(MarkStoryAsSeenRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkStoryAsSeenProvider._internal(
        (ref) => create(ref as MarkStoryAsSeenRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _MarkStoryAsSeenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkStoryAsSeenProvider && other.storyId == storyId;
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
mixin MarkStoryAsSeenRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _MarkStoryAsSeenProviderElement
    extends AutoDisposeFutureProviderElement<bool> with MarkStoryAsSeenRef {
  _MarkStoryAsSeenProviderElement(super.provider);

  @override
  String get storyId => (origin as MarkStoryAsSeenProvider).storyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
