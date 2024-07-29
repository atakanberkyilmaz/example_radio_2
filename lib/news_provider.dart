import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsProvider with ChangeNotifier {
  List<Map<String, String>> _news = [];
  bool _isLoading = true;
  String _currentLang = 'en';

  List<Map<String, String>> get news => _news;
  bool get isLoading => _isLoading;
  String get currentLang => _currentLang;

  NewsProvider() {
    fetchNews(_currentLang); // Default language
  }

  Future<void> fetchNews(String toLang) async {
    _isLoading = true;
    notifyListeners();

    final url = await _getNewsURL();
    if (url != null) {
      try {
        final response = await Dio().get(url);
        if (response.statusCode == 200) {
          final document = xml.XmlDocument.parse(response.data);
          final items = document.findAllElements('item');

          if (toLang != 'en') {
            final translator = GoogleTranslator();
            _news = await Future.wait(items.map((item) async {
              String title = item.findElements('title').single.text;
              String description = item.findElements('description').single.text;

              String translatedTitle = await _translateText(title, toLang, translator);
              String translatedDescription = await _translateText(description, toLang, translator);

              return {
                'title': translatedTitle,
                'description': translatedDescription,
              };
            }).toList());
          } else {
            final translator = GoogleTranslator();
            _news = await Future.wait(items.map((item) async {
              String title = item.findElements('title').single.text;
              String description = item.findElements('description').single.text;

              String translatedTitle = await _translateText(title, toLang, translator);
              String translatedDescription = await _translateText(description, toLang, translator);

              return {
                'title': translatedTitle,
                'description': translatedDescription,
              };
            }).toList());
          }
        } else {
          print("Error: ${response.statusMessage}");
        }
      } catch (e) {
        print("Error fetching news: $e");
      }
    } else {
      print("URL not found in Firestore");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> _getNewsURL() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('news').doc('news_url_eng').get();
      if (snapshot.exists) {
        return snapshot.data()?['url'];
      }
    } catch (e) {
      print("Error fetching news URL from Firestore: $e");
    }
    return null;
  }

  Future<String> _translateText(String text, String toLang, GoogleTranslator translator) async {
    try {
      var translation = await translator.translate(text, from: 'auto', to: toLang);
      return translation.text;
    } catch (e) {
      print("Error translating text: $e");
      return text; // Hata durumunda orijinal metni döndür
    }
  }

  void changeLanguage(String newLang) {
    if (_currentLang != newLang) {
      _currentLang = newLang;
      fetchNews(newLang);
    }
  }
}
