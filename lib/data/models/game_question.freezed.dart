// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameQuestionResponse _$GameQuestionResponseFromJson(Map<String, dynamic> json) {
  return _GameQuestionResponse.fromJson(json);
}

/// @nodoc
mixin _$GameQuestionResponse {
  int get total => throw _privateConstructorUsedError;
  List<GameQuestion> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get pages => throw _privateConstructorUsedError;

  /// Serializes this GameQuestionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameQuestionResponseCopyWith<GameQuestionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameQuestionResponseCopyWith<$Res> {
  factory $GameQuestionResponseCopyWith(GameQuestionResponse value,
          $Res Function(GameQuestionResponse) then) =
      _$GameQuestionResponseCopyWithImpl<$Res, GameQuestionResponse>;
  @useResult
  $Res call(
      {int total, List<GameQuestion> items, int page, int size, int pages});
}

/// @nodoc
class _$GameQuestionResponseCopyWithImpl<$Res,
        $Val extends GameQuestionResponse>
    implements $GameQuestionResponseCopyWith<$Res> {
  _$GameQuestionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? pages = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GameQuestion>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameQuestionResponseImplCopyWith<$Res>
    implements $GameQuestionResponseCopyWith<$Res> {
  factory _$$GameQuestionResponseImplCopyWith(_$GameQuestionResponseImpl value,
          $Res Function(_$GameQuestionResponseImpl) then) =
      __$$GameQuestionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total, List<GameQuestion> items, int page, int size, int pages});
}

/// @nodoc
class __$$GameQuestionResponseImplCopyWithImpl<$Res>
    extends _$GameQuestionResponseCopyWithImpl<$Res, _$GameQuestionResponseImpl>
    implements _$$GameQuestionResponseImplCopyWith<$Res> {
  __$$GameQuestionResponseImplCopyWithImpl(_$GameQuestionResponseImpl _value,
      $Res Function(_$GameQuestionResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? pages = null,
  }) {
    return _then(_$GameQuestionResponseImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GameQuestion>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameQuestionResponseImpl implements _GameQuestionResponse {
  const _$GameQuestionResponseImpl(
      {required this.total,
      required final List<GameQuestion> items,
      required this.page,
      required this.size,
      required this.pages})
      : _items = items;

  factory _$GameQuestionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameQuestionResponseImplFromJson(json);

  @override
  final int total;
  final List<GameQuestion> _items;
  @override
  List<GameQuestion> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  final int size;
  @override
  final int pages;

  @override
  String toString() {
    return 'GameQuestionResponse(total: $total, items: $items, page: $page, size: $size, pages: $pages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameQuestionResponseImpl &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.pages, pages) || other.pages == pages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total,
      const DeepCollectionEquality().hash(_items), page, size, pages);

  /// Create a copy of GameQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameQuestionResponseImplCopyWith<_$GameQuestionResponseImpl>
      get copyWith =>
          __$$GameQuestionResponseImplCopyWithImpl<_$GameQuestionResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameQuestionResponseImplToJson(
      this,
    );
  }
}

abstract class _GameQuestionResponse implements GameQuestionResponse {
  const factory _GameQuestionResponse(
      {required final int total,
      required final List<GameQuestion> items,
      required final int page,
      required final int size,
      required final int pages}) = _$GameQuestionResponseImpl;

  factory _GameQuestionResponse.fromJson(Map<String, dynamic> json) =
      _$GameQuestionResponseImpl.fromJson;

  @override
  int get total;
  @override
  List<GameQuestion> get items;
  @override
  int get page;
  @override
  int get size;
  @override
  int get pages;

  /// Create a copy of GameQuestionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameQuestionResponseImplCopyWith<_$GameQuestionResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GameQuestion _$GameQuestionFromJson(Map<String, dynamic> json) {
  return _GameQuestion.fromJson(json);
}

/// @nodoc
mixin _$GameQuestion {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'game_type')
  int get gameType => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  List<GameOption> get options => throw _privateConstructorUsedError;

  /// Serializes this GameQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameQuestionCopyWith<GameQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameQuestionCopyWith<$Res> {
  factory $GameQuestionCopyWith(
          GameQuestion value, $Res Function(GameQuestion) then) =
      _$GameQuestionCopyWithImpl<$Res, GameQuestion>;
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'game_type') int gameType,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'created_at') String createdAt,
      List<GameOption> options});
}

/// @nodoc
class _$GameQuestionCopyWithImpl<$Res, $Val extends GameQuestion>
    implements $GameQuestionCopyWith<$Res> {
  _$GameQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? gameType = null,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      gameType: null == gameType
          ? _value.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<GameOption>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameQuestionImplCopyWith<$Res>
    implements $GameQuestionCopyWith<$Res> {
  factory _$$GameQuestionImplCopyWith(
          _$GameQuestionImpl value, $Res Function(_$GameQuestionImpl) then) =
      __$$GameQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      @JsonKey(name: 'game_type') int gameType,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'created_at') String createdAt,
      List<GameOption> options});
}

/// @nodoc
class __$$GameQuestionImplCopyWithImpl<$Res>
    extends _$GameQuestionCopyWithImpl<$Res, _$GameQuestionImpl>
    implements _$$GameQuestionImplCopyWith<$Res> {
  __$$GameQuestionImplCopyWithImpl(
      _$GameQuestionImpl _value, $Res Function(_$GameQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? gameType = null,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? options = null,
  }) {
    return _then(_$GameQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      gameType: null == gameType
          ? _value.gameType
          : gameType // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<GameOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameQuestionImpl implements _GameQuestion {
  const _$GameQuestionImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'game_type') required this.gameType,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'created_at') required this.createdAt,
      required final List<GameOption> options})
      : _options = options;

  factory _$GameQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameQuestionImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'game_type')
  final int gameType;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  final List<GameOption> _options;
  @override
  List<GameOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'GameQuestion(id: $id, title: $title, gameType: $gameType, imageUrl: $imageUrl, createdAt: $createdAt, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, gameType, imageUrl,
      createdAt, const DeepCollectionEquality().hash(_options));

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameQuestionImplCopyWith<_$GameQuestionImpl> get copyWith =>
      __$$GameQuestionImplCopyWithImpl<_$GameQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameQuestionImplToJson(
      this,
    );
  }
}

abstract class _GameQuestion implements GameQuestion {
  const factory _GameQuestion(
      {required final int id,
      required final String title,
      @JsonKey(name: 'game_type') required final int gameType,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'created_at') required final String createdAt,
      required final List<GameOption> options}) = _$GameQuestionImpl;

  factory _GameQuestion.fromJson(Map<String, dynamic> json) =
      _$GameQuestionImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'game_type')
  int get gameType;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  List<GameOption> get options;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameQuestionImplCopyWith<_$GameQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameOption _$GameOptionFromJson(Map<String, dynamic> json) {
  return _GameOption.fromJson(json);
}

/// @nodoc
mixin _$GameOption {
  int get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_correct')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'question_id')
  int get questionId => throw _privateConstructorUsedError;

  /// Serializes this GameOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameOptionCopyWith<GameOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameOptionCopyWith<$Res> {
  factory $GameOptionCopyWith(
          GameOption value, $Res Function(GameOption) then) =
      _$GameOptionCopyWithImpl<$Res, GameOption>;
  @useResult
  $Res call(
      {int id,
      String text,
      @JsonKey(name: 'is_correct') bool isCorrect,
      @JsonKey(name: 'question_id') int questionId});
}

/// @nodoc
class _$GameOptionCopyWithImpl<$Res, $Val extends GameOption>
    implements $GameOptionCopyWith<$Res> {
  _$GameOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
    Object? questionId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameOptionImplCopyWith<$Res>
    implements $GameOptionCopyWith<$Res> {
  factory _$$GameOptionImplCopyWith(
          _$GameOptionImpl value, $Res Function(_$GameOptionImpl) then) =
      __$$GameOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String text,
      @JsonKey(name: 'is_correct') bool isCorrect,
      @JsonKey(name: 'question_id') int questionId});
}

/// @nodoc
class __$$GameOptionImplCopyWithImpl<$Res>
    extends _$GameOptionCopyWithImpl<$Res, _$GameOptionImpl>
    implements _$$GameOptionImplCopyWith<$Res> {
  __$$GameOptionImplCopyWithImpl(
      _$GameOptionImpl _value, $Res Function(_$GameOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
    Object? questionId = null,
  }) {
    return _then(_$GameOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameOptionImpl implements _GameOption {
  const _$GameOptionImpl(
      {required this.id,
      required this.text,
      @JsonKey(name: 'is_correct') required this.isCorrect,
      @JsonKey(name: 'question_id') required this.questionId});

  factory _$GameOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String text;
  @override
  @JsonKey(name: 'is_correct')
  final bool isCorrect;
  @override
  @JsonKey(name: 'question_id')
  final int questionId;

  @override
  String toString() {
    return 'GameOption(id: $id, text: $text, isCorrect: $isCorrect, questionId: $questionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, isCorrect, questionId);

  /// Create a copy of GameOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameOptionImplCopyWith<_$GameOptionImpl> get copyWith =>
      __$$GameOptionImplCopyWithImpl<_$GameOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameOptionImplToJson(
      this,
    );
  }
}

abstract class _GameOption implements GameOption {
  const factory _GameOption(
          {required final int id,
          required final String text,
          @JsonKey(name: 'is_correct') required final bool isCorrect,
          @JsonKey(name: 'question_id') required final int questionId}) =
      _$GameOptionImpl;

  factory _GameOption.fromJson(Map<String, dynamic> json) =
      _$GameOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get text;
  @override
  @JsonKey(name: 'is_correct')
  bool get isCorrect;
  @override
  @JsonKey(name: 'question_id')
  int get questionId;

  /// Create a copy of GameOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameOptionImplCopyWith<_$GameOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameAttempt _$GameAttemptFromJson(Map<String, dynamic> json) {
  return _GameAttempt.fromJson(json);
}

/// @nodoc
mixin _$GameAttempt {
  @JsonKey(name: 'standalone_question_id')
  int get questionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'selected_option_id')
  int get selectedOptionId => throw _privateConstructorUsedError;

  /// Serializes this GameAttempt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameAttemptCopyWith<GameAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameAttemptCopyWith<$Res> {
  factory $GameAttemptCopyWith(
          GameAttempt value, $Res Function(GameAttempt) then) =
      _$GameAttemptCopyWithImpl<$Res, GameAttempt>;
  @useResult
  $Res call(
      {@JsonKey(name: 'standalone_question_id') int questionId,
      @JsonKey(name: 'selected_option_id') int selectedOptionId});
}

/// @nodoc
class _$GameAttemptCopyWithImpl<$Res, $Val extends GameAttempt>
    implements $GameAttemptCopyWith<$Res> {
  _$GameAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? selectedOptionId = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptionId: null == selectedOptionId
          ? _value.selectedOptionId
          : selectedOptionId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameAttemptImplCopyWith<$Res>
    implements $GameAttemptCopyWith<$Res> {
  factory _$$GameAttemptImplCopyWith(
          _$GameAttemptImpl value, $Res Function(_$GameAttemptImpl) then) =
      __$$GameAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'standalone_question_id') int questionId,
      @JsonKey(name: 'selected_option_id') int selectedOptionId});
}

/// @nodoc
class __$$GameAttemptImplCopyWithImpl<$Res>
    extends _$GameAttemptCopyWithImpl<$Res, _$GameAttemptImpl>
    implements _$$GameAttemptImplCopyWith<$Res> {
  __$$GameAttemptImplCopyWithImpl(
      _$GameAttemptImpl _value, $Res Function(_$GameAttemptImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameAttempt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? selectedOptionId = null,
  }) {
    return _then(_$GameAttemptImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedOptionId: null == selectedOptionId
          ? _value.selectedOptionId
          : selectedOptionId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameAttemptImpl implements _GameAttempt {
  const _$GameAttemptImpl(
      {@JsonKey(name: 'standalone_question_id') required this.questionId,
      @JsonKey(name: 'selected_option_id') required this.selectedOptionId});

  factory _$GameAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameAttemptImplFromJson(json);

  @override
  @JsonKey(name: 'standalone_question_id')
  final int questionId;
  @override
  @JsonKey(name: 'selected_option_id')
  final int selectedOptionId;

  @override
  String toString() {
    return 'GameAttempt(questionId: $questionId, selectedOptionId: $selectedOptionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameAttemptImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.selectedOptionId, selectedOptionId) ||
                other.selectedOptionId == selectedOptionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionId, selectedOptionId);

  /// Create a copy of GameAttempt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameAttemptImplCopyWith<_$GameAttemptImpl> get copyWith =>
      __$$GameAttemptImplCopyWithImpl<_$GameAttemptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameAttemptImplToJson(
      this,
    );
  }
}

abstract class _GameAttempt implements GameAttempt {
  const factory _GameAttempt(
      {@JsonKey(name: 'standalone_question_id') required final int questionId,
      @JsonKey(name: 'selected_option_id')
      required final int selectedOptionId}) = _$GameAttemptImpl;

  factory _GameAttempt.fromJson(Map<String, dynamic> json) =
      _$GameAttemptImpl.fromJson;

  @override
  @JsonKey(name: 'standalone_question_id')
  int get questionId;
  @override
  @JsonKey(name: 'selected_option_id')
  int get selectedOptionId;

  /// Create a copy of GameAttempt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameAttemptImplCopyWith<_$GameAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
