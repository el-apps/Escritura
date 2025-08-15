import 'package:bible_parser_flutter/bible_parser_flutter.dart';
import 'package:flutter/material.dart';

class BibleService {
  late BibleParser _parser;
  late List<Book> _books;
  late Map<String, Book> _booksMap;

  List<Book> get books => _books;
  Map<String, Book> get booksMap => _booksMap;

  Future<BibleService> load(BuildContext context) async {
    final xmlString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/kjv.xml');
    _parser = BibleParser.fromString(xmlString, format: 'OSIS');
    _books = (await _parser.books.toList())
        .where((b) => b.title != 'Unknown')
        .toList();
    _booksMap = Map.fromEntries(_books.map((b) => MapEntry(b.id, b)));
    return this;
  }

  List<Chapter> getChapters(String bookId) {
    return _booksMap[bookId]?.chapters ?? [];
  }

  List<Verse> getVerses(String bookId, int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > getChapters(bookId).length) {
      return [];
    }
    return getChapters(bookId)[chapterNumber - 1].verses;
  }

  String getVerse(String bookId, int chapterNumber, int verseNumber) {
    if (verseNumber < 1 ||
        verseNumber > getVerses(bookId, chapterNumber).length) {
      return '';
    }
    return getVerses(bookId, chapterNumber)[verseNumber - 1].text;
  }
}
