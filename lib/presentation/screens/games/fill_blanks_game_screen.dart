import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:knowledge/presentation/screens/games/base_game_screen.dart';

class FillBlanksGameScreen extends ConsumerWidget {
  const FillBlanksGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseGameScreen(
      gameId: 'fill_blanks',
      gameTitle: 'Fragments',
      gameType: kFillBlanksGameType,
    );
  }
}
