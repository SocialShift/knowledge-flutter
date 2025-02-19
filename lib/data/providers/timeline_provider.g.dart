// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineNotifierHash() => r'c27a213b4e68e56c7d4ef343029e5811f9b4154d';

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

abstract class _$TimelineNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Timeline> {
  late final String timelineId;

  FutureOr<Timeline> build(
    String timelineId,
  );
}

/// See also [TimelineNotifier].
@ProviderFor(TimelineNotifier)
const timelineNotifierProvider = TimelineNotifierFamily();

/// See also [TimelineNotifier].
class TimelineNotifierFamily extends Family<AsyncValue<Timeline>> {
  /// See also [TimelineNotifier].
  const TimelineNotifierFamily();

  /// See also [TimelineNotifier].
  TimelineNotifierProvider call(
    String timelineId,
  ) {
    return TimelineNotifierProvider(
      timelineId,
    );
  }

  @override
  TimelineNotifierProvider getProviderOverride(
    covariant TimelineNotifierProvider provider,
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
  String? get name => r'timelineNotifierProvider';
}

/// See also [TimelineNotifier].
class TimelineNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TimelineNotifier, Timeline> {
  /// See also [TimelineNotifier].
  TimelineNotifierProvider(
    String timelineId,
  ) : this._internal(
          () => TimelineNotifier()..timelineId = timelineId,
          from: timelineNotifierProvider,
          name: r'timelineNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timelineNotifierHash,
          dependencies: TimelineNotifierFamily._dependencies,
          allTransitiveDependencies:
              TimelineNotifierFamily._allTransitiveDependencies,
          timelineId: timelineId,
        );

  TimelineNotifierProvider._internal(
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
  FutureOr<Timeline> runNotifierBuild(
    covariant TimelineNotifier notifier,
  ) {
    return notifier.build(
      timelineId,
    );
  }

  @override
  Override overrideWith(TimelineNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TimelineNotifierProvider._internal(
        () => create()..timelineId = timelineId,
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
  AutoDisposeAsyncNotifierProviderElement<TimelineNotifier, Timeline>
      createElement() {
    return _TimelineNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineNotifierProvider && other.timelineId == timelineId;
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
mixin TimelineNotifierRef on AutoDisposeAsyncNotifierProviderRef<Timeline> {
  /// The parameter `timelineId` of this provider.
  String get timelineId;
}

class _TimelineNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TimelineNotifier, Timeline>
    with TimelineNotifierRef {
  _TimelineNotifierProviderElement(super.provider);

  @override
  String get timelineId => (origin as TimelineNotifierProvider).timelineId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
