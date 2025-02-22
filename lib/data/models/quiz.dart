import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

@freezed
class Quiz with _$Quiz {
  const factory Quiz({
    required String id,
    required String storyId,
    required List<Question> questions,
    required String title,
    @Default(false) bool isCompleted,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
}

@freezed
class Question with _$Question {
  const factory Question({
    required String id,
    required String text,
    required List<Option> options,
    required int correctOptionIndex,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
class Option with _$Option {
  const factory Option({
    required String id,
    required String text,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}
