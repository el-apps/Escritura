import 'package:escritura/practice_result.dart';
import 'package:flutter/material.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key, required this.memorizationResults});

  // TODO: fetch these from the DB
  final List<MemorizationResult> memorizationResults;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Share Your Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Daily sharing your results with others is a great way to practice accountability!',
          ),
          // TODO: allow the user to determine what data they want to share
          //       for example, they may want to share their memorization but
          //       not their reference identification results
          for (final (:ref, :attempts) in memorizationResults)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // TODO: get prettier string from bible service
              children: [Text('$ref'), Text(attempts == 1 ? '🎉' : '✅')],
            ),
        ],
      ),
      actions: [
        // TODO: add share button
      ],
    );
  }
}
