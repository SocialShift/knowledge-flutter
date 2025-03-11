import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/quiz.dart';
import 'package:knowledge/data/repositories/quiz_repository.dart';

part 'quiz_provider.g.dart';

@riverpod
class QuizNotifier extends _$QuizNotifier {
  @override
  AsyncValue<Quiz> build(String storyId) {
    // Use the repository to fetch the quiz
    final quizAsync = ref.watch(storyQuizProvider(storyId));

    // Convert AsyncValue<Quiz?> to AsyncValue<Quiz>
    return quizAsync.when(
      data: (quiz) => quiz != null
          ? AsyncValue.data(quiz)
          : AsyncValue.data(_demoQuiz), // Use demo quiz as fallback
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }

  // Demo data for fallback if needed
  static final Quiz _demoQuiz = Quiz(
    id: '1',
    title: 'Test Your Knowledge',
    description: 'Test your knowledge about this historical event',
    questions: [
      Question(
        id: '1',
        text: 'What year did the French Revolution begin?',
        options: [
          Option(id: '1', text: '1789', isCorrect: true),
          Option(id: '2', text: '1790'),
          Option(id: '3', text: '1788'),
          Option(id: '4', text: '1791'),
        ],
        correctOptionId: '1',
        points: 10,
        explanation:
            'The French Revolution began in 1789 with the storming of the Bastille.',
      ),
      Question(
        id: '2',
        text: 'Who was the first President of the United States?',
        options: [
          Option(id: '1', text: 'Thomas Jefferson'),
          Option(id: '2', text: 'George Washington', isCorrect: true),
          Option(id: '3', text: 'John Adams'),
          Option(id: '4', text: 'Benjamin Franklin'),
        ],
        correctOptionId: '2',
        points: 10,
        explanation:
            'George Washington was the first President of the United States, serving from 1789 to 1797.',
      ),
    ],
  );
}
