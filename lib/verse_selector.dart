import 'package:escritura/bible_service.dart';
import 'package:escritura/scripture_ref.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerseSelector extends StatelessWidget {
  const VerseSelector({super.key, required this.ref, required this.onSelected});

  final ScriptureRef ref;
  final Function(ScriptureRef) onSelected;

  @override
  Widget build(BuildContext context) {
    final bibleService = context.read<BibleService>();
    return ListTile(
      title: Text(bibleService.getRefName(ref)),
      trailing: Icon(Icons.chevron_right),
      onTap: () => _openSelectorDialog(context),
    );
  }

  void _openSelectorDialog(BuildContext context) async {
    final bibleService = context.read<BibleService>();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.brown),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              DropdownMenu(
                width: double.infinity,
                dropdownMenuEntries: bibleService.books
                    .map<DropdownMenuEntry<String>>(
                      (book) =>
                          DropdownMenuEntry(value: book.id, label: book.title),
                    )
                    .toList(),
                onSelected: (bookId) => onSelected(
                  ref.copyWith(
                    bookId: bookId,
                    chapterNumber: ref.chapterNumber ?? 1,
                    verseNumber: ref.verseNumber ?? 1,
                  ),
                ),
              ),
              if (ref.bookId != null)
                Row(
                  spacing: 8,
                  children: [
                    if (ref.bookId != null)
                      Expanded(
                        child: DropdownMenu(
                          expandedInsets: EdgeInsets.zero,
                          initialSelection: ref.chapterNumber,
                          dropdownMenuEntries:
                              (bibleService.getChapters(ref.bookId!))
                                  .map<DropdownMenuEntry<int>>(
                                    (chapter) => DropdownMenuEntry(
                                      value: chapter.num,
                                      label: chapter.num.toString(),
                                    ),
                                  )
                                  .toList(),
                          onSelected: (chapterNumber) => onSelected(
                            ref.copyWith(
                              chapterNumber: chapterNumber,
                              verseNumber: ref.verseNumber ?? 1,
                            ),
                          ),
                        ),
                      ),
                    if (ref.chapterNumber != null)
                      Expanded(
                        child: DropdownMenu(
                          expandedInsets: EdgeInsets.zero,
                          initialSelection: ref.verseNumber,
                          dropdownMenuEntries:
                              (bibleService.getVerses(
                                    ref.bookId!,
                                    ref.chapterNumber!,
                                  ))
                                  .map<DropdownMenuEntry<int>>(
                                    (verse) => DropdownMenuEntry(
                                      value: verse.num,
                                      label: verse.num.toString(),
                                    ),
                                  )
                                  .toList(),
                          onSelected: (verseNumber) => onSelected(
                            ref.copyWith(verseNumber: verseNumber),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
