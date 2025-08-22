import 'package:escritura/practice_result.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key, required this.memorizationResults});

  // TODO: fetch these from the DB
  final List<MemorizationResult> memorizationResults;

  String get _shareContent => [
    [
      'Memorization',
      ...memorizationResults
      // TODO: get prettier string from bible service
      .map((result) => '${result.attempts == 1 ? "🎉" : "✅"} ${result.ref}'),
    ].join('\n'),
    // TODO: add results from other parts of the app
  ].where((section) => section.isNotEmpty).join('----------\n');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Share Your Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily sharing your results with others is a great way to practice accountability!',
          ),
          if (_shareContent.isNotEmpty) Divider(),
          Text(_shareContent),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        if (_shareContent.isNotEmpty)
          TextButton(onPressed: () => _share(context), child: Text('Share')),
      ],
    );
  }

  _share(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(text: 'Escritura Daily Results\n\n$_shareContent'),
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
