import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/repositories/game_repository.dart';
import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

part 'game_provider.g.dart';

// Constants for game types
const int kGuessYearGameType = 1;
const int kImageGuessGameType = 2;
const int kFillBlanksGameType = 3;

// Provider for fetching game questions based on game type
@riverpod
Future<List<GameQuestion>> gameQuestions(
    GameQuestionsRef ref, int gameType) async {
  final repository = ref.watch(gameRepositoryProvider);

  try {
    // Attempt to fetch from API
    final response = await repository.getGameQuestions(gameType);

    // Parse the response
    final questionsResponse = GameQuestionResponse.fromJson(response);
    return questionsResponse.items;
  } catch (e) {
    DebugUtils.debugError('Error in gameQuestions provider: $e');

    // Create appropriate mock data based on game type
    if (gameType == kGuessYearGameType) {
      return _createMockGuessYearQuestions();
    } else if (gameType == kImageGuessGameType) {
      return _createMockImageGuessQuestions();
    } else if (gameType == kFillBlanksGameType) {
      return _createMockFillBlanksQuestions();
    } else {
      // Default fallback
      return _createMockGuessYearQuestions();
    }
  }
}

// Mock data functions
List<GameQuestion> _createMockGuessYearQuestions() {
  return [
    GameQuestion(
      id: 1,
      title: 'When did World War II end?',
      gameType: kGuessYearGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 1,
          text: '1945',
          isCorrect: true,
          questionId: 1,
        ),
        GameOption(
          id: 2,
          text: '1939',
          isCorrect: false,
          questionId: 1,
        ),
        GameOption(
          id: 3,
          text: '1950',
          isCorrect: false,
          questionId: 1,
        ),
        GameOption(
          id: 4,
          text: '1942',
          isCorrect: false,
          questionId: 1,
        ),
      ],
    ),
    GameQuestion(
      id: 2,
      title: 'When was the United Nations founded?',
      gameType: kGuessYearGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 5,
          text: '1945',
          isCorrect: true,
          questionId: 2,
        ),
        GameOption(
          id: 6,
          text: '1950',
          isCorrect: false,
          questionId: 2,
        ),
        GameOption(
          id: 7,
          text: '1948',
          isCorrect: false,
          questionId: 2,
        ),
        GameOption(
          id: 8,
          text: '1955',
          isCorrect: false,
          questionId: 2,
        ),
      ],
    ),
    GameQuestion(
      id: 3,
      title: 'In what year did the Berlin Wall fall?',
      gameType: kGuessYearGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 9,
          text: '1989',
          isCorrect: true,
          questionId: 3,
        ),
        GameOption(
          id: 10,
          text: '1991',
          isCorrect: false,
          questionId: 3,
        ),
        GameOption(
          id: 11,
          text: '1985',
          isCorrect: false,
          questionId: 3,
        ),
        GameOption(
          id: 12,
          text: '1995',
          isCorrect: false,
          questionId: 3,
        ),
      ],
    ),
  ];
}

List<GameQuestion> _createMockImageGuessQuestions() {
  return [
    GameQuestion(
      id: 4,
      title: 'Who is this person?',
      gameType: kImageGuessGameType,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/a/ab/Abraham_Lincoln_O-77_matte_collodion_print.jpg',
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 13,
          text: 'Abraham Lincoln',
          isCorrect: true,
          questionId: 4,
        ),
        GameOption(
          id: 14,
          text: 'George Washington',
          isCorrect: false,
          questionId: 4,
        ),
        GameOption(
          id: 15,
          text: 'Thomas Jefferson',
          isCorrect: false,
          questionId: 4,
        ),
        GameOption(
          id: 16,
          text: 'John Adams',
          isCorrect: false,
          questionId: 4,
        ),
      ],
    ),
    GameQuestion(
      id: 5,
      title: 'Identify this historical figure:',
      gameType: kImageGuessGameType,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/79/Gandhi_Kheda_1918.jpg',
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 17,
          text: 'Mahatma Gandhi',
          isCorrect: true,
          questionId: 5,
        ),
        GameOption(
          id: 18,
          text: 'Jawaharlal Nehru',
          isCorrect: false,
          questionId: 5,
        ),
        GameOption(
          id: 19,
          text: 'Nelson Mandela',
          isCorrect: false,
          questionId: 5,
        ),
        GameOption(
          id: 20,
          text: 'Martin Luther King Jr.',
          isCorrect: false,
          questionId: 5,
        ),
      ],
    ),
    GameQuestion(
      id: 6,
      title: 'Who is pictured here?',
      gameType: kImageGuessGameType,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/8/8d/Marie_Curie_1903.jpg',
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 21,
          text: 'Marie Curie',
          isCorrect: true,
          questionId: 6,
        ),
        GameOption(
          id: 22,
          text: 'Rosalind Franklin',
          isCorrect: false,
          questionId: 6,
        ),
        GameOption(
          id: 23,
          text: 'Jane Austen',
          isCorrect: false,
          questionId: 6,
        ),
        GameOption(
          id: 24,
          text: 'Ada Lovelace',
          isCorrect: false,
          questionId: 6,
        ),
      ],
    ),
  ];
}

List<GameQuestion> _createMockFillBlanksQuestions() {
  return [
    GameQuestion(
      id: 7,
      title: 'I have a _____ that one day this nation will rise up.',
      gameType: kFillBlanksGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 25,
          text: 'dream',
          isCorrect: true,
          questionId: 7,
        ),
        GameOption(
          id: 26,
          text: 'hope',
          isCorrect: false,
          questionId: 7,
        ),
        GameOption(
          id: 27,
          text: 'belief',
          isCorrect: false,
          questionId: 7,
        ),
        GameOption(
          id: 28,
          text: 'vision',
          isCorrect: false,
          questionId: 7,
        ),
      ],
    ),
    GameQuestion(
      id: 8,
      title:
          'Ask not what your country can do for you, ask what you can do for your _____.',
      gameType: kFillBlanksGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 29,
          text: 'country',
          isCorrect: true,
          questionId: 8,
        ),
        GameOption(
          id: 30,
          text: 'nation',
          isCorrect: false,
          questionId: 8,
        ),
        GameOption(
          id: 31,
          text: 'government',
          isCorrect: false,
          questionId: 8,
        ),
        GameOption(
          id: 32,
          text: 'people',
          isCorrect: false,
          questionId: 8,
        ),
      ],
    ),
    GameQuestion(
      id: 9,
      title: 'That\'s one small step for man, one giant _____ for mankind.',
      gameType: kFillBlanksGameType,
      imageUrl: null,
      createdAt: DateTime.now().toIso8601String(),
      options: [
        GameOption(
          id: 33,
          text: 'leap',
          isCorrect: true,
          questionId: 9,
        ),
        GameOption(
          id: 34,
          text: 'step',
          isCorrect: false,
          questionId: 9,
        ),
        GameOption(
          id: 35,
          text: 'journey',
          isCorrect: false,
          questionId: 9,
        ),
        GameOption(
          id: 36,
          text: 'achievement',
          isCorrect: false,
          questionId: 9,
        ),
      ],
    ),
  ];
}

// Game state class
class GameState {
  final List<GameQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final bool isGameOver;
  final bool? lastAnswerCorrect;
  final int? lastSelectedOptionId;

  GameState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.isGameOver = false,
    this.lastAnswerCorrect,
    this.lastSelectedOptionId,
  });

  GameState copyWith({
    List<GameQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    bool? isGameOver,
    bool? lastAnswerCorrect,
    int? lastSelectedOptionId,
  }) {
    return GameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      isGameOver: isGameOver ?? this.isGameOver,
      lastAnswerCorrect: lastAnswerCorrect,
      lastSelectedOptionId: lastSelectedOptionId,
    );
  }

  GameQuestion? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  bool get hasActiveFilters => false;

  int get activeFilterCount => 0;
}

// Provider for game state
@riverpod
class GameStateNotifier extends _$GameStateNotifier {
  @override
  GameState build() {
    return GameState();
  }

  void setQuestions(List<GameQuestion> questions) {
    // Randomize the order of questions
    final shuffledQuestions = List<GameQuestion>.from(questions);
    shuffledQuestions.shuffle(Random());

    state = state.copyWith(
      questions: shuffledQuestions,
      currentQuestionIndex: 0,
      score: 0,
      isGameOver: false,
      lastAnswerCorrect: null,
      lastSelectedOptionId: null,
    );
  }

  Future<bool> submitAnswer(int optionId) async {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return false;

    final selectedOption = currentQuestion.options.firstWhere(
      (option) => option.id == optionId,
      orElse: () => currentQuestion.options.first,
    );

    try {
      // Submit the answer to the API
      final repository = ref.read(gameRepositoryProvider);
      await repository.submitGameAttempt(currentQuestion.id, optionId);

      // Update the game state
      final isCorrect = selectedOption.isCorrect;
      final newScore = state.score + (isCorrect ? 10 : 0);
      // Don't increment the currentQuestionIndex here - wait for nextQuestion() call
      final isGameOver =
          state.currentQuestionIndex + 1 >= state.questions.length;

      state = state.copyWith(
        score: newScore,
        isGameOver: isGameOver,
        lastAnswerCorrect: isCorrect,
        lastSelectedOptionId: optionId,
      );

      return isCorrect;
    } catch (e) {
      DebugUtils.debugError('Error submitting answer: $e');

      // Still update local state for testing purposes
      final isCorrect = selectedOption.isCorrect;
      final newScore = state.score + (isCorrect ? 10 : 0);
      // Don't increment the currentQuestionIndex here - wait for nextQuestion() call
      final isGameOver =
          state.currentQuestionIndex + 1 >= state.questions.length;

      state = state.copyWith(
        score: newScore,
        isGameOver: isGameOver,
        lastAnswerCorrect: isCorrect,
        lastSelectedOptionId: optionId,
      );

      return isCorrect;
    }
  }

  void nextQuestion() {
    if (state.isGameOver) return;

    final newIndex = state.currentQuestionIndex + 1;
    final isGameOver = newIndex >= state.questions.length;

    state = state.copyWith(
      currentQuestionIndex: newIndex,
      isGameOver: isGameOver,
      lastAnswerCorrect: null,
      lastSelectedOptionId: null,
    );
  }

  void restartGame() {
    if (state.questions.isEmpty) return;

    // Shuffle questions again
    final shuffledQuestions = List<GameQuestion>.from(state.questions);
    shuffledQuestions.shuffle(Random());

    state = state.copyWith(
      questions: shuffledQuestions,
      currentQuestionIndex: 0,
      score: 0,
      isGameOver: false,
      lastAnswerCorrect: null,
      lastSelectedOptionId: null,
    );
  }
}
