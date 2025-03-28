// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MainCharacter _$MainCharacterFromJson(Map<String, dynamic> json) {
  return _MainCharacter.fromJson(json);
}

/// @nodoc
mixin _$MainCharacter {
  String get id => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  String get persona => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MainCharacter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MainCharacter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MainCharacterCopyWith<MainCharacter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainCharacterCopyWith<$Res> {
  factory $MainCharacterCopyWith(
          MainCharacter value, $Res Function(MainCharacter) then) =
      _$MainCharacterCopyWithImpl<$Res, MainCharacter>;
  @useResult
  $Res call({String id, String avatarUrl, String persona, String? createdAt});
}

/// @nodoc
class _$MainCharacterCopyWithImpl<$Res, $Val extends MainCharacter>
    implements $MainCharacterCopyWith<$Res> {
  _$MainCharacterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MainCharacter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarUrl = null,
    Object? persona = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      persona: null == persona
          ? _value.persona
          : persona // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MainCharacterImplCopyWith<$Res>
    implements $MainCharacterCopyWith<$Res> {
  factory _$$MainCharacterImplCopyWith(
          _$MainCharacterImpl value, $Res Function(_$MainCharacterImpl) then) =
      __$$MainCharacterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String avatarUrl, String persona, String? createdAt});
}

/// @nodoc
class __$$MainCharacterImplCopyWithImpl<$Res>
    extends _$MainCharacterCopyWithImpl<$Res, _$MainCharacterImpl>
    implements _$$MainCharacterImplCopyWith<$Res> {
  __$$MainCharacterImplCopyWithImpl(
      _$MainCharacterImpl _value, $Res Function(_$MainCharacterImpl) _then)
      : super(_value, _then);

  /// Create a copy of MainCharacter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? avatarUrl = null,
    Object? persona = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$MainCharacterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      persona: null == persona
          ? _value.persona
          : persona // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MainCharacterImpl implements _MainCharacter {
  const _$MainCharacterImpl(
      {required this.id,
      required this.avatarUrl,
      required this.persona,
      this.createdAt});

  factory _$MainCharacterImpl.fromJson(Map<String, dynamic> json) =>
      _$$MainCharacterImplFromJson(json);

  @override
  final String id;
  @override
  final String avatarUrl;
  @override
  final String persona;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'MainCharacter(id: $id, avatarUrl: $avatarUrl, persona: $persona, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainCharacterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.persona, persona) || other.persona == persona) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, avatarUrl, persona, createdAt);

  /// Create a copy of MainCharacter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MainCharacterImplCopyWith<_$MainCharacterImpl> get copyWith =>
      __$$MainCharacterImplCopyWithImpl<_$MainCharacterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MainCharacterImplToJson(
      this,
    );
  }
}

abstract class _MainCharacter implements MainCharacter {
  const factory _MainCharacter(
      {required final String id,
      required final String avatarUrl,
      required final String persona,
      final String? createdAt}) = _$MainCharacterImpl;

  factory _MainCharacter.fromJson(Map<String, dynamic> json) =
      _$MainCharacterImpl.fromJson;

  @override
  String get id;
  @override
  String get avatarUrl;
  @override
  String get persona;
  @override
  String? get createdAt;

  /// Create a copy of MainCharacter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MainCharacterImplCopyWith<_$MainCharacterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Timeline _$TimelineFromJson(Map<String, dynamic> json) {
  return _Timeline.fromJson(json);
}

/// @nodoc
mixin _$Timeline {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  MainCharacter? get mainCharacter => throw _privateConstructorUsedError;
  List<Story> get stories => throw _privateConstructorUsedError;

  /// Serializes this Timeline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineCopyWith<Timeline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineCopyWith<$Res> {
  factory $TimelineCopyWith(Timeline value, $Res Function(Timeline) then) =
      _$TimelineCopyWithImpl<$Res, Timeline>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      int year,
      MainCharacter? mainCharacter,
      List<Story> stories});

  $MainCharacterCopyWith<$Res>? get mainCharacter;
}

/// @nodoc
class _$TimelineCopyWithImpl<$Res, $Val extends Timeline>
    implements $TimelineCopyWith<$Res> {
  _$TimelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? year = null,
    Object? mainCharacter = freezed,
    Object? stories = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      mainCharacter: freezed == mainCharacter
          ? _value.mainCharacter
          : mainCharacter // ignore: cast_nullable_to_non_nullable
              as MainCharacter?,
      stories: null == stories
          ? _value.stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
    ) as $Val);
  }

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MainCharacterCopyWith<$Res>? get mainCharacter {
    if (_value.mainCharacter == null) {
      return null;
    }

    return $MainCharacterCopyWith<$Res>(_value.mainCharacter!, (value) {
      return _then(_value.copyWith(mainCharacter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimelineImplCopyWith<$Res>
    implements $TimelineCopyWith<$Res> {
  factory _$$TimelineImplCopyWith(
          _$TimelineImpl value, $Res Function(_$TimelineImpl) then) =
      __$$TimelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      int year,
      MainCharacter? mainCharacter,
      List<Story> stories});

  @override
  $MainCharacterCopyWith<$Res>? get mainCharacter;
}

/// @nodoc
class __$$TimelineImplCopyWithImpl<$Res>
    extends _$TimelineCopyWithImpl<$Res, _$TimelineImpl>
    implements _$$TimelineImplCopyWith<$Res> {
  __$$TimelineImplCopyWithImpl(
      _$TimelineImpl _value, $Res Function(_$TimelineImpl) _then)
      : super(_value, _then);

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? year = null,
    Object? mainCharacter = freezed,
    Object? stories = null,
  }) {
    return _then(_$TimelineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      mainCharacter: freezed == mainCharacter
          ? _value.mainCharacter
          : mainCharacter // ignore: cast_nullable_to_non_nullable
              as MainCharacter?,
      stories: null == stories
          ? _value._stories
          : stories // ignore: cast_nullable_to_non_nullable
              as List<Story>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelineImpl implements _Timeline {
  _$TimelineImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.year,
      this.mainCharacter,
      final List<Story> stories = const []})
      : _stories = stories;

  factory _$TimelineImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final int year;
  @override
  final MainCharacter? mainCharacter;
  final List<Story> _stories;
  @override
  @JsonKey()
  List<Story> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  String toString() {
    return 'Timeline(id: $id, title: $title, description: $description, imageUrl: $imageUrl, year: $year, mainCharacter: $mainCharacter, stories: $stories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.mainCharacter, mainCharacter) ||
                other.mainCharacter == mainCharacter) &&
            const DeepCollectionEquality().equals(other._stories, _stories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, imageUrl,
      year, mainCharacter, const DeepCollectionEquality().hash(_stories));

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineImplCopyWith<_$TimelineImpl> get copyWith =>
      __$$TimelineImplCopyWithImpl<_$TimelineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineImplToJson(
      this,
    );
  }
}

abstract class _Timeline implements Timeline {
  factory _Timeline(
      {required final String id,
      required final String title,
      required final String description,
      required final String imageUrl,
      required final int year,
      final MainCharacter? mainCharacter,
      final List<Story> stories}) = _$TimelineImpl;

  factory _Timeline.fromJson(Map<String, dynamic> json) =
      _$TimelineImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  int get year;
  @override
  MainCharacter? get mainCharacter;
  @override
  List<Story> get stories;

  /// Create a copy of Timeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineImplCopyWith<_$TimelineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Story _$StoryFromJson(Map<String, dynamic> json) {
  return _Story.fromJson(json);
}

/// @nodoc
mixin _$Story {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String get mediaType => throw _privateConstructorUsedError;
  String get mediaUrl => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<Timestamp> get timestamps => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  String? get timelineId => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get storyDate => throw _privateConstructorUsedError;

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryCopyWith<Story> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCopyWith<$Res> {
  factory $StoryCopyWith(Story value, $Res Function(Story) then) =
      _$StoryCopyWithImpl<$Res, Story>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      int year,
      bool isCompleted,
      String mediaType,
      String mediaUrl,
      String content,
      List<Timestamp> timestamps,
      int likes,
      int views,
      String? timelineId,
      String? createdAt,
      String? storyDate});
}

/// @nodoc
class _$StoryCopyWithImpl<$Res, $Val extends Story>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? year = null,
    Object? isCompleted = null,
    Object? mediaType = null,
    Object? mediaUrl = null,
    Object? content = null,
    Object? timestamps = null,
    Object? likes = null,
    Object? views = null,
    Object? timelineId = freezed,
    Object? createdAt = freezed,
    Object? storyDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamps: null == timestamps
          ? _value.timestamps
          : timestamps // ignore: cast_nullable_to_non_nullable
              as List<Timestamp>,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      timelineId: freezed == timelineId
          ? _value.timelineId
          : timelineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      storyDate: freezed == storyDate
          ? _value.storyDate
          : storyDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoryImplCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$$StoryImplCopyWith(
          _$StoryImpl value, $Res Function(_$StoryImpl) then) =
      __$$StoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      int year,
      bool isCompleted,
      String mediaType,
      String mediaUrl,
      String content,
      List<Timestamp> timestamps,
      int likes,
      int views,
      String? timelineId,
      String? createdAt,
      String? storyDate});
}

/// @nodoc
class __$$StoryImplCopyWithImpl<$Res>
    extends _$StoryCopyWithImpl<$Res, _$StoryImpl>
    implements _$$StoryImplCopyWith<$Res> {
  __$$StoryImplCopyWithImpl(
      _$StoryImpl _value, $Res Function(_$StoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? year = null,
    Object? isCompleted = null,
    Object? mediaType = null,
    Object? mediaUrl = null,
    Object? content = null,
    Object? timestamps = null,
    Object? likes = null,
    Object? views = null,
    Object? timelineId = freezed,
    Object? createdAt = freezed,
    Object? storyDate = freezed,
  }) {
    return _then(_$StoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamps: null == timestamps
          ? _value._timestamps
          : timestamps // ignore: cast_nullable_to_non_nullable
              as List<Timestamp>,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      timelineId: freezed == timelineId
          ? _value.timelineId
          : timelineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      storyDate: freezed == storyDate
          ? _value.storyDate
          : storyDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryImpl implements _Story {
  _$StoryImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.year,
      this.isCompleted = false,
      this.mediaType = '',
      this.mediaUrl = '',
      this.content = '',
      final List<Timestamp> timestamps = const [],
      this.likes = 0,
      this.views = 0,
      this.timelineId,
      this.createdAt,
      this.storyDate})
      : _timestamps = timestamps;

  factory _$StoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final int year;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final String mediaType;
  @override
  @JsonKey()
  final String mediaUrl;
  @override
  @JsonKey()
  final String content;
  final List<Timestamp> _timestamps;
  @override
  @JsonKey()
  List<Timestamp> get timestamps {
    if (_timestamps is EqualUnmodifiableListView) return _timestamps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timestamps);
  }

  @override
  @JsonKey()
  final int likes;
  @override
  @JsonKey()
  final int views;
  @override
  final String? timelineId;
  @override
  final String? createdAt;
  @override
  final String? storyDate;

  @override
  String toString() {
    return 'Story(id: $id, title: $title, description: $description, imageUrl: $imageUrl, year: $year, isCompleted: $isCompleted, mediaType: $mediaType, mediaUrl: $mediaUrl, content: $content, timestamps: $timestamps, likes: $likes, views: $views, timelineId: $timelineId, createdAt: $createdAt, storyDate: $storyDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._timestamps, _timestamps) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.timelineId, timelineId) ||
                other.timelineId == timelineId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.storyDate, storyDate) ||
                other.storyDate == storyDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imageUrl,
      year,
      isCompleted,
      mediaType,
      mediaUrl,
      content,
      const DeepCollectionEquality().hash(_timestamps),
      likes,
      views,
      timelineId,
      createdAt,
      storyDate);

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      __$$StoryImplCopyWithImpl<_$StoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryImplToJson(
      this,
    );
  }
}

abstract class _Story implements Story {
  factory _Story(
      {required final String id,
      required final String title,
      required final String description,
      required final String imageUrl,
      required final int year,
      final bool isCompleted,
      final String mediaType,
      final String mediaUrl,
      final String content,
      final List<Timestamp> timestamps,
      final int likes,
      final int views,
      final String? timelineId,
      final String? createdAt,
      final String? storyDate}) = _$StoryImpl;

  factory _Story.fromJson(Map<String, dynamic> json) = _$StoryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  int get year;
  @override
  bool get isCompleted;
  @override
  String get mediaType;
  @override
  String get mediaUrl;
  @override
  String get content;
  @override
  List<Timestamp> get timestamps;
  @override
  int get likes;
  @override
  int get views;
  @override
  String? get timelineId;
  @override
  String? get createdAt;
  @override
  String? get storyDate;

  /// Create a copy of Story
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryImplCopyWith<_$StoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Timestamp _$TimestampFromJson(Map<String, dynamic> json) {
  return _Timestamp.fromJson(json);
}

/// @nodoc
mixin _$Timestamp {
  String? get id => throw _privateConstructorUsedError;
  String? get storyId => throw _privateConstructorUsedError;
  int get timeSec => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this Timestamp to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Timestamp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimestampCopyWith<Timestamp> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimestampCopyWith<$Res> {
  factory $TimestampCopyWith(Timestamp value, $Res Function(Timestamp) then) =
      _$TimestampCopyWithImpl<$Res, Timestamp>;
  @useResult
  $Res call({String? id, String? storyId, int timeSec, String label});
}

/// @nodoc
class _$TimestampCopyWithImpl<$Res, $Val extends Timestamp>
    implements $TimestampCopyWith<$Res> {
  _$TimestampCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Timestamp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? storyId = freezed,
    Object? timeSec = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      storyId: freezed == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSec: null == timeSec
          ? _value.timeSec
          : timeSec // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimestampImplCopyWith<$Res>
    implements $TimestampCopyWith<$Res> {
  factory _$$TimestampImplCopyWith(
          _$TimestampImpl value, $Res Function(_$TimestampImpl) then) =
      __$$TimestampImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? storyId, int timeSec, String label});
}

/// @nodoc
class __$$TimestampImplCopyWithImpl<$Res>
    extends _$TimestampCopyWithImpl<$Res, _$TimestampImpl>
    implements _$$TimestampImplCopyWith<$Res> {
  __$$TimestampImplCopyWithImpl(
      _$TimestampImpl _value, $Res Function(_$TimestampImpl) _then)
      : super(_value, _then);

  /// Create a copy of Timestamp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? storyId = freezed,
    Object? timeSec = null,
    Object? label = null,
  }) {
    return _then(_$TimestampImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      storyId: freezed == storyId
          ? _value.storyId
          : storyId // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSec: null == timeSec
          ? _value.timeSec
          : timeSec // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimestampImpl implements _Timestamp {
  const _$TimestampImpl(
      {this.id, this.storyId, required this.timeSec, required this.label});

  factory _$TimestampImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimestampImplFromJson(json);

  @override
  final String? id;
  @override
  final String? storyId;
  @override
  final int timeSec;
  @override
  final String label;

  @override
  String toString() {
    return 'Timestamp(id: $id, storyId: $storyId, timeSec: $timeSec, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimestampImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storyId, storyId) || other.storyId == storyId) &&
            (identical(other.timeSec, timeSec) || other.timeSec == timeSec) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, storyId, timeSec, label);

  /// Create a copy of Timestamp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimestampImplCopyWith<_$TimestampImpl> get copyWith =>
      __$$TimestampImplCopyWithImpl<_$TimestampImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimestampImplToJson(
      this,
    );
  }
}

abstract class _Timestamp implements Timestamp {
  const factory _Timestamp(
      {final String? id,
      final String? storyId,
      required final int timeSec,
      required final String label}) = _$TimestampImpl;

  factory _Timestamp.fromJson(Map<String, dynamic> json) =
      _$TimestampImpl.fromJson;

  @override
  String? get id;
  @override
  String? get storyId;
  @override
  int get timeSec;
  @override
  String get label;

  /// Create a copy of Timestamp
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimestampImplCopyWith<_$TimestampImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
