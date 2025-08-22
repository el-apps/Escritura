import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture_ref.freezed.dart';

@freezed
abstract class ScriptureRef with _$ScriptureRef {
  const ScriptureRef._();

  const factory ScriptureRef({
    String? bookId,
    int? chapterNumber,
    int? verseNumber,
  }) = _ScriptureRef;

  bool get complete =>
      bookId != null && chapterNumber != null && verseNumber != null;

  @override
  toString() {
    if (bookId == null) {
      return 'Unknown';
    }
    if (chapterNumber == null) {
      return bookId!;
    }
    if (verseNumber == null) {
      return '$bookId $chapterNumber';
    }
    return '$bookId $chapterNumber:$verseNumber';
  }
}
