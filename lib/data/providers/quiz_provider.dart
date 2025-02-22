import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/quiz.dart';

part 'quiz_provider.g.dart';

@riverpod
class QuizNotifier extends _$QuizNotifier {
  @override
  AsyncValue<Quiz> build(String storyId) {
    // TODO: Fetch quiz from API
    return AsyncValue.data(_demoQuiz);
  }

  // Demo data
  static final Quiz _demoQuiz = Quiz(
    id: '1',
    storyId: '1',
    title: 'Test Your Knowledge',
    questions: [
      Question(
        id: '1',
        text: 'What year did the French Revolution begin?',
        options: [
          Option(id: '1', text: '1789'),
          Option(id: '2', text: '1790'),
          Option(id: '3', text: '1788'),
          Option(id: '4', text: '1791'),
        ],
        correctOptionIndex: 0,
      ),
      Question(
        id: '2',
        text: 'Who was the first President of the United States?',
        options: [
          Option(id: '1', text: 'Thomas Jefferson'),
          Option(id: '2', text: 'George Washington'),
          Option(id: '3', text: 'John Adams'),
          Option(id: '4', text: 'Benjamin Franklin'),
        ],
        correctOptionIndex: 1,
      ),
      // Add more demo questions...
    ],
  );
}
