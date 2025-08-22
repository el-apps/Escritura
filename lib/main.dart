import 'package:escritura/bible_service.dart';
import 'package:escritura/home_page.dart';
import 'package:escritura/verse_memorization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const EscrituraApp());
}

class EscrituraApp extends StatefulWidget {
  const EscrituraApp({super.key});

  @override
  State<EscrituraApp> createState() => _EscrituraAppState();
}

class _EscrituraAppState extends State<EscrituraApp> {
  late BibleService _bibleService;
  late Future _bibleFuture;

  @override
  void initState() {
    super.initState();
    _bibleService = BibleService();
    _bibleFuture = _bibleService.load(context);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _bibleFuture,
    builder: (context, asyncSnapshot) => _bibleService.isLoaded
        ? Provider.value(
            value: _bibleService,
            child: MaterialApp(
              title: 'Escritura',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.brown,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              home: HomePage(),
            ),
          )
        : Center(child: CircularProgressIndicator()),
  );
}
