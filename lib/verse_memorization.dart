import 'package:escritura/bible_service.dart';
import 'package:escritura/scripture_ref.dart';
import 'package:escritura/verse_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_tools/word_tools.dart';

class VerseMemorization extends StatefulWidget {
  const VerseMemorization({super.key});

  @override
  State<VerseMemorization> createState() => _VerseMemorizationState();
}

class _VerseMemorizationState extends State<VerseMemorization> {
  ScriptureRef _ref = ScriptureRef();
  late TextEditingController _inputController;
  String _input = '';
  Result _result = Result.unknown;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final bibleService = context.read<BibleService>();
    final actualVerse = bibleService.hasVerse(_ref)
        ? bibleService.getVerse(
            _ref.bookId!,
            _ref.chapterNumber!,
            _ref.verseNumber!,
          )
        : '';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            VerseSelector(
              onSelected: (ref) => setState(() {
                _ref = ref;
                _clear();
              }),
            ),
            if (_result != Result.unknown && bibleService.hasVerse(_ref))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.brown),
                ),
                child: Text(
                  actualVerse,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            if (bibleService.hasVerse(_ref))
              TextFormField(
                controller: _inputController,
                autofocus: true,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter the verse here. Voice input is recommended!",
                ),
                onChanged: (String value) => setState(() => _input = value),
              ),
            if (_result != Result.unknown)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _result.color),
                ),
                child: Text(switch (_result) {
                  Result.incorrect => 'Try again',
                  Result.correct => 'Correct!',
                  // This case should never be reached
                  Result.unknown => '',
                }, style: Theme.of(context).textTheme.bodyLarge),
              ),
            if (_input.isNotEmpty && _result != Result.correct)
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _clear,
                      child: Text('Clear'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _gradeSubmission(actualVerse),
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            // TODO: after getting a correct answer, show a button to go to
            //       the next verse in the user's list
          ],
        ),
      ),
    );
  }

  void _clear() => setState(() {
    _inputController.clear();
    _input = '';
    _result = Result.unknown;
  });

  void _gradeSubmission(String actualVerse) {
    if (kDebugMode) {
      print(actualVerse);
      print(_input);
    }
    setState(
      () => _result = doWordSequencesMatch(actualVerse, _input)
          ? Result.correct
          : Result.incorrect,
    );
  }
}

enum Result {
  unknown(color: Colors.brown),
  incorrect(color: Colors.red),
  correct(color: Colors.green);

  final Color color;

  const Result({required this.color});
}
