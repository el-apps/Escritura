import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:flutter/material.dart';

class BibleService {
  late BibleParser _parser;
  late List<Book> _books;
  late Map<String, Book> _booksMap;

  List<Book> get books => _books;
  Map<String, Book> get booksMap => _booksMap;

  load(BuildContext context) async {
    final xmlString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/kjv.xml');
    _parser = BibleParser.fromString(xmlString, format: 'USFX');
    _books = (await _parser.books.toList())
        .where((b) => b.title != 'Unknown')
        .toList();
    _booksMap = Map.fromEntries(_books.map((b) => MapEntry(b.id, b)));
    return this;
  }
}
