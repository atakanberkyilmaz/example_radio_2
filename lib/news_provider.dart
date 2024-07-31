import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:html/parser.dart' as parser;

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
    print("News URL: $url");
    if (url != null && url.isNotEmpty) {
      try {
        final response = await Dio().get(url);
        if (response.statusCode == 200) {
          final document = parser.parse(response.data);

          // Güncellenen HTML elementlerini burada hedefleyin
          final items = document.querySelectorAll('li.row.feed__item');
          print("Items found: ${items.length}");

          if (toLang != 'en') {
            final translator = GoogleTranslator();
            _news = await Future.wait(items.map((item) async {
              String title = item.querySelector('h3.feed__title a')?.text.trim() ?? '';
              String description = item.querySelector('p.feed__description')?.text.trim() ?? '';
              String link = item.querySelector('h3.feed__title a')?.attributes['href'] ?? '';
              if (link.isNotEmpty && !link.startsWith('http')) {
                link = 'https://www.constructiondive.com$link';
              }
              String imageUrl = await _fetchImageURL(link);
              String translatedTitle = await _translateText(title, toLang, translator);
              String translatedDescription = await _translateText(description, toLang, translator);
              await Future.delayed(Duration(milliseconds: 500)); // Gecikme ekleyin
              return {
                'title': translatedTitle,
                'description': translatedDescription,
                'image': imageUrl,
                'link': link,
              };
            }).toList());
          } else {
            _news = await Future.wait(items.map((item) async {
              String title = item.querySelector('h3.feed__title a')?.text.trim() ?? '';
              String description = item.querySelector('p.feed__description')?.text.trim() ?? '';
              String link = item.querySelector('h3.feed__title a')?.attributes['href'] ?? '';
              if (link.isNotEmpty && !link.startsWith('http')) {
                link = 'https://www.constructiondive.com$link';
              }
              String imageUrl = await _fetchImageURL(link);
              await Future.delayed(Duration(milliseconds: 500)); // Gecikme ekleyin
              return {
                'title': title,
                'description': description,
                'image': imageUrl,
                'link': link,
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

  Future<String> _fetchImageURL(String newsLink) async {
    try {
      final response = await Dio().get(newsLink);
      if (response.statusCode == 200) {
        final document = parser.parse(response.data);
        final imageUrl = document.querySelector('meta[name="sailthru.image.full"]')?.attributes['content'] ??
            document.querySelector('meta[name="sailthru.image.thumb"]')?.attributes['content'] ?? '';
        return imageUrl;
      }
    } catch (e) {
      print("Error fetching image URL: $e");
    }
    return '';
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
    var translation = await translator.translate(text, to: toLang);
    return translation.text;
  }

  void changeLanguage(String newLang) {
    _currentLang = newLang;
    fetchNews(newLang);
  }
}
