import 'package:escritura/bible_service.dart';
import 'package:flutter/material.dart';

class VerseViewer extends StatefulWidget {
  const VerseViewer({super.key});

  @override
  State<StatefulWidget> createState() => _VerseViewerState();
}

class _VerseViewerState extends State<VerseViewer> {
  String? selectedBookId;
  int? selectedChapterNumber;
  int? selectedVerseNumber;

  @override
  Widget build(BuildContext context) {
    final bibleService = BibleService();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown),
      ),
      child: FutureBuilder(
        future: bibleService.load(context),
        builder: (BuildContext context, AsyncSnapshot<BibleService> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error!'));
          } else if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                DropdownMenu(
                  width: double.infinity,
                  dropdownMenuEntries: snapshot.data!.books
                      .map<DropdownMenuEntry<String>>(
                        (book) => DropdownMenuEntry(
                          value: book.id,
                          label: book.title,
                        ),
                      )
                      .toList(),
                  onSelected: (id) => setState(() => selectedBookId = id),
                ),
                if (selectedBookId != null)
                  DropdownMenu(
                    width: double.infinity,
                    dropdownMenuEntries:
                        (snapshot.data!.getChapters(selectedBookId!))
                            .map<DropdownMenuEntry<int>>(
                              (chapter) => DropdownMenuEntry(
                                value: chapter.num,
                                label: chapter.num.toString(),
                              ),
                            )
                            .toList(),
                    onSelected: (chapterNum) =>
                        setState(() => selectedChapterNumber = chapterNum),
                  ),
                if (selectedChapterNumber != null)
                  DropdownMenu(
                    width: double.infinity,
                    dropdownMenuEntries:
                        (snapshot.data!.getVerses(
                              selectedBookId!,
                              selectedChapterNumber!,
                            ))
                            .map<DropdownMenuEntry<int>>(
                              (verse) => DropdownMenuEntry(
                                value: verse.num,
                                label: verse.num.toString(),
                              ),
                            )
                            .toList(),
                    onSelected: (verseNum) =>
                        setState(() => selectedVerseNumber = verseNum),
                  ),
                if (selectedVerseNumber != null)
                  Text(
                    snapshot.data!.getVerse(
                      selectedBookId!,
                      selectedChapterNumber!,
                      selectedVerseNumber!,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
