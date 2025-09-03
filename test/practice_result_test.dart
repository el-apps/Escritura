import 'package:escritura/practice_result.dart';
import 'package:escritura/scripture_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemorizationResult', () {
    test('scoreString returns 🎉 for 1 attempt and score of 0.9', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 1,
        score: 0.9,
      );
      expect(result.scoreString, '🎉');
    });

    test('scoreString returns 🎉 for 1 attempt and score of 1.0', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 1,
        score: 1.0,
      );
      expect(result.scoreString, '🎉');
    });

    test('scoreString returns ✅ for 1 attempt and score of 0.89', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 1,
        score: 0.89,
      );
      expect(result.scoreString, '✅');
    });

    test('scoreString returns ✅ for 1 attempt and score of 0.0', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 1,
        score: 0.0,
      );
      expect(result.scoreString, '✅');
    });

    test('scoreString returns ♻️ for attempts > 1 and score of 0.9', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 2,
        score: 0.9,
      );
      expect(result.scoreString, '♻️');
    });

    test('scoreString returns ♻️ for attempts > 1 and score of 0.5', () {
      final result = MemorizationResult(
        ref: ScriptureRef(bookId: 'John', chapterNumber: 3, verseNumber: 16),
        attempts: 3,
        score: 0.5,
      );
      expect(result.scoreString, '♻️');
    });
  });
}
