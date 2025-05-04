import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_question.freezed.dart';
part 'game_question.g.dart';

@freezed
class GameQuestionResponse with _$GameQuestionResponse {
  const factory GameQuestionResponse({
    required int total,
    required List<GameQuestion> items,
    required int page,
    required int size,
    required int pages,
  }) = _GameQuestionResponse;

  factory GameQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$GameQuestionResponseFromJson(json);
}

@freezed
class GameQuestion with _$GameQuestion {
  const factory GameQuestion({
    required int id,
    required String title,
    @JsonKey(name: 'game_type') required int gameType,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required String createdAt,
    required List<GameOption> options,
  }) = _GameQuestion;

  factory GameQuestion.fromJson(Map<String, dynamic> json) =>
      _$GameQuestionFromJson(json);
}

@freezed
class GameOption with _$GameOption {
  const factory GameOption({
    required int id,
    required String text,
    @JsonKey(name: 'is_correct') required bool isCorrect,
    @JsonKey(name: 'question_id') required int questionId,
  }) = _GameOption;

  factory GameOption.fromJson(Map<String, dynamic> json) =>
      _$GameOptionFromJson(json);
}

@freezed
class GameAttempt with _$GameAttempt {
  const factory GameAttempt({
    @JsonKey(name: 'standalone_question_id') required int questionId,
    @JsonKey(name: 'selected_option_id') required int selectedOptionId,
  }) = _GameAttempt;

  factory GameAttempt.fromJson(Map<String, dynamic> json) =>
      _$GameAttemptFromJson(json);
}

// Enum to define game types
enum GameType {
  guessTheYear(1),
  imageGuess(2),
  fillInTheBlank(3);

  const GameType(this.value);
  final int value;

  factory GameType.fromValue(int value) {
    return GameType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GameType.guessTheYear,
    );
  }
}
