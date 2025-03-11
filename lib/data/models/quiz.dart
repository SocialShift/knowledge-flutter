import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

@freezed
class Quiz with _$Quiz {
  factory Quiz({
    required String id,
    required String title,
    required String description,
    required List<Question> questions,
    String? storyId,
    @Default(0) int totalPoints,
    @Default(false) bool isCompleted,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  // Factory constructor to create a Quiz from the API response
  static Quiz fromApiResponse(Map<String, dynamic> json) {
    // Parse questions from the API response
    final List<Question> questions = [];
    if (json['questions'] != null && json['questions'] is List) {
      for (var questionJson in json['questions']) {
        questions.add(Question.fromApiResponse(questionJson));
      }
    }

    return Quiz(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Quiz',
      description: json['description'] ?? '',
      storyId: json['story_id']?.toString(),
      totalPoints: json['total_points'] ??
          questions.length * 10, // Default 10 points per question
      isCompleted: json['is_completed'] ?? false,
      questions: questions,
    );
  }
}

@freezed
class Question with _$Question {
  factory Question({
    required String id,
    required String text,
    required List<Option> options,
    String? correctOptionId,
    @Default(10) int points,
    @Default('') String explanation,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  // Factory constructor to create a Question from the API response
  static Question fromApiResponse(Map<String, dynamic> json) {
    // Parse options from the API response
    final List<Option> options = [];
    if (json['options'] != null && json['options'] is List) {
      for (var optionJson in json['options']) {
        options.add(Option.fromApiResponse(optionJson));
      }
    }

    return Question(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      options: options,
      correctOptionId: json['correct_option_id']?.toString(),
      points: json['points'] ?? 10,
      explanation: json['explanation'] ?? '',
    );
  }
}

@freezed
class Option with _$Option {
  factory Option({
    required String id,
    required String text,
    @Default(false) bool isCorrect,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);

  // Factory constructor to create an Option from the API response
  static Option fromApiResponse(Map<String, dynamic> json) {
    return Option(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}
