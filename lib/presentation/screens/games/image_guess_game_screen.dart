import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/game_provider.dart';
import 'package:knowledge/presentation/screens/games/base_game_screen.dart';

class ImageGuessGameScreen extends ConsumerWidget {
  const ImageGuessGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BaseGameScreen(
      gameId: 'image_guess',
      gameTitle: 'Legacy',
      gameType: kImageGuessGameType,
    );
  }
}
