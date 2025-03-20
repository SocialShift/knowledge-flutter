import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_provider.g.dart';

class FilterState {
  final String race;
  final String gender;
  final String sexualOrientation;
  final List<String> interests;
  final String searchQuery;

  const FilterState({
    this.race = '',
    this.gender = '',
    this.sexualOrientation = '',
    this.interests = const [],
    this.searchQuery = '',
  });

  FilterState copyWith({
    String? race,
    String? gender,
    String? sexualOrientation,
    List<String>? interests,
    String? searchQuery,
  }) {
    return FilterState(
      race: race ?? this.race,
      gender: gender ?? this.gender,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      interests: interests ?? this.interests,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Helper method to check if any filters are active
  bool get hasActiveFilters {
    return race.isNotEmpty ||
        gender.isNotEmpty ||
        sexualOrientation.isNotEmpty ||
        interests.isNotEmpty;
  }

  // Helper method to count active filters
  int get activeFilterCount {
    int count = 0;
    if (race.isNotEmpty) count++;
    if (gender.isNotEmpty) count++;
    if (sexualOrientation.isNotEmpty) count++;
    if (interests.isNotEmpty) count++;
    return count;
  }
}

@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() {
    return const FilterState();
  }

  void updateRace(String race) {
    state = state.copyWith(race: race);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateSexualOrientation(String sexualOrientation) {
    state = state.copyWith(sexualOrientation: sexualOrientation);
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.interests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }
    state = state.copyWith(interests: currentInterests);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const FilterState();
  }
}
