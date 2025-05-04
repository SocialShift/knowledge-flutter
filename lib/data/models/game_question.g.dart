// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameQuestionResponseImpl _$$GameQuestionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GameQuestionResponseImpl(
      total: (json['total'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => GameQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$$GameQuestionResponseImplToJson(
        _$GameQuestionResponseImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'items': instance.items,
      'page': instance.page,
      'size': instance.size,
      'pages': instance.pages,
    };

_$GameQuestionImpl _$$GameQuestionImplFromJson(Map<String, dynamic> json) =>
    _$GameQuestionImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      gameType: (json['game_type'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => GameOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GameQuestionImplToJson(_$GameQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'game_type': instance.gameType,
      'image_url': instance.imageUrl,
      'created_at': instance.createdAt,
      'options': instance.options,
    };

_$GameOptionImpl _$$GameOptionImplFromJson(Map<String, dynamic> json) =>
    _$GameOptionImpl(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
      questionId: (json['question_id'] as num).toInt(),
    );

Map<String, dynamic> _$$GameOptionImplToJson(_$GameOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'is_correct': instance.isCorrect,
      'question_id': instance.questionId,
    };

_$GameAttemptImpl _$$GameAttemptImplFromJson(Map<String, dynamic> json) =>
    _$GameAttemptImpl(
      questionId: (json['standalone_question_id'] as num).toInt(),
      selectedOptionId: (json['selected_option_id'] as num).toInt(),
    );

Map<String, dynamic> _$$GameAttemptImplToJson(_$GameAttemptImpl instance) =>
    <String, dynamic>{
      'standalone_question_id': instance.questionId,
      'selected_option_id': instance.selectedOptionId,
    };
