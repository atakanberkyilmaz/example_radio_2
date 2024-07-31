import 'package:dio/dio.dart';
import 'package:translator/translator.dart';
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';

class NewsDetailProvider with ChangeNotifier {
  Map<String, String> _newsDetail = {};
  bool _isLoading = true;
  String _currentLang = 'en';

  Map<String, String> get newsDetail => _newsDetail;
  bool get isLoading => _isLoading;
  String get currentLang => _currentLang;

  NewsDetailProvider();

  Future<void> fetchNewsDetail(String url, String toLang) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final document = parser.parse(response.data);

        // Sayfa başlığını ve içerik açıklamasını alın
        String title = document.querySelector('h1')?.text.trim() ?? '';
        String content = document.querySelector('div.article-body')?.text.trim() ?? '';

        // Resim URL'sini alın
        String imageUrl = document.querySelector('meta[name="sailthru.image.full"]')?.attributes['content'] ??
            document.querySelector('meta[name="sailthru.image.thumb"]')?.attributes['content'] ?? '';

        // Çeviri gerekiyorsa metinleri çevirin
        if (toLang != 'en') {
          final translator = GoogleTranslator();
          title = await _translateText(title, toLang, translator);
          content = await _translateText(content, toLang, translator);
        }

        _newsDetail = {
          'title': title,
          'content': content,
          'image': imageUrl,
        };
      } else {
        print("Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Error fetching news detail: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> _translateText(String text, String toLang, GoogleTranslator translator) async {
    var translation = await translator.translate(text, to: toLang);
    return translation.text;
  }

  void changeLanguage(String newLang) {
    _currentLang = newLang;
    fetchNewsDetail(_newsDetail['link'] ?? '', newLang);
  }
}
