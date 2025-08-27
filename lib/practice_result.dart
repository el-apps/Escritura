import 'package:escritura/scripture_ref.dart';

class MemorizationResult {
  MemorizationResult({
    required this.ref,
    required this.attempts,
    required this.score,
  });
  final ScriptureRef ref;
  final int attempts;
  final double score;

  String get scoreString => switch (score) {
    == 1 => "🟩🟩🟩🟩🟩",
    >= 0.8 => "🟩🟩🟩🟩⬜",
    >= 0.6 => "🟨🟨🟨⬜⬜",
    >= 0.4 => "🟨🟨⬜⬜⬜",
    >= 0.2 => "🟨⬜⬜⬜⬜",
    _ => "⬜⬜⬜⬜⬜",
  };
}
