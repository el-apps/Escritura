import 'package:escritura/bible_service.dart';
import 'package:escritura/scripture_ref.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerseSelector extends StatefulWidget {
  const VerseSelector({super.key, required this.onSelected});

  final Function(ScriptureRef) onSelected;

  @override
  State<StatefulWidget> createState() => _VerseSelectorState();
}

class _VerseSelectorState extends State<VerseSelector> {
  ScriptureRef _selectedRef = ScriptureRef();

  @override
  Widget build(BuildContext context) {
    final bibleService = context.read<BibleService>();
    return Container(
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
            onSelected: (bookId) =>
                _select(_selectedRef.copyWith(bookId: bookId)),
          ),
          if (_selectedRef.bookId != null)
            Row(
              spacing: 8,
              children: [
                if (_selectedRef.bookId != null)
                  Expanded(
                    child: DropdownMenu(
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries:
                          (bibleService.getChapters(_selectedRef.bookId!))
                              .map<DropdownMenuEntry<int>>(
                                (chapter) => DropdownMenuEntry(
                                  value: chapter.num,
                                  label: chapter.num.toString(),
                                ),
                              )
                              .toList(),
                      onSelected: (chapterNumber) => _select(
                        _selectedRef.copyWith(chapterNumber: chapterNumber),
                      ),
                    ),
                  ),
                if (_selectedRef.chapterNumber != null)
                  Expanded(
                    child: DropdownMenu(
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries:
                          (bibleService.getVerses(
                                _selectedRef.bookId!,
                                _selectedRef.chapterNumber!,
                              ))
                              .map<DropdownMenuEntry<int>>(
                                (verse) => DropdownMenuEntry(
                                  value: verse.num,
                                  label: verse.num.toString(),
                                ),
                              )
                              .toList(),
                      onSelected: (verseNumber) => _select(
                        _selectedRef.copyWith(verseNumber: verseNumber),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  _select(ScriptureRef ref) {
    setState(() => _selectedRef = ref);
    widget.onSelected(ref);
  }
}
