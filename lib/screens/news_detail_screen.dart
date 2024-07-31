import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../news_detail_provider.dart';

class NewsDetailScreen extends StatelessWidget {
  final String url;

  NewsDetailScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    final newsDetailProvider = Provider.of<NewsDetailProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newsDetailProvider.isLoading) {
        newsDetailProvider.fetchNewsDetail(url, newsDetailProvider.currentLang);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('News Detail'),
        actions: [
          DropdownButton<String>(
            value: newsDetailProvider.currentLang,
            icon: Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.blue,
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('English', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'tr',
                child: Text('Türkçe', style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                newsDetailProvider.changeLanguage(newValue);
              }
            },
            underline: Container(),
          ),
        ],
      ),
      body: newsDetailProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : newsDetailProvider.newsDetail.isEmpty
          ? Center(child: Text('Failed to load news detail after multiple attempts.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newsDetailProvider.newsDetail['title'] ?? '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              CachedNetworkImage(
                imageUrl: newsDetailProvider.newsDetail['image'] ?? '',
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              SizedBox(height: 10),
              Text(newsDetailProvider.newsDetail['content'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
