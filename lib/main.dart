import 'package:escritura/verse_viewer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escritura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const EscrituraHomePage(),
    );
  }
}

class EscrituraHomePage extends StatefulWidget {
  const EscrituraHomePage({super.key});

  @override
  State<EscrituraHomePage> createState() => _EscrituraHomePageState();
}

class _EscrituraHomePageState extends State<EscrituraHomePage> {
  String input = '';
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Escritura'),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              VerseViewer(),
              result.isEmpty
                  ? TextFormField(
                      maxLines: 5,
                      initialValue: input,
                      onChanged: (String value) =>
                          setState(() => input = value),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        result,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => setState(() {
                        input = '';
                        result = '';
                      }),
                      child: Text('Clear'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => setState(() => result = 'Coming soon!'),
                      child: Text('Submit'),
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
