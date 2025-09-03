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

  String get scoreString => switch ((attempts, score)) {
    (1, >= 0.9) => '🎉',
    (1, _) => '✅',
    _ => '♻️',
  };
}
