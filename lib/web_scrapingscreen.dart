import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../news_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WebScrapingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        actions: [
          DropdownButton<String>(
            value: Provider.of<NewsProvider>(context).currentLang,
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
                final newsProvider = Provider.of<NewsProvider>(context, listen: false);
                newsProvider.changeLanguage(newValue);
              }
            },
            underline: Container(),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: newsProvider.news.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(newsProvider.news[index]['title']!),
                  subtitle: Text(newsProvider.news[index]['description']!),
                  leading: newsProvider.news[index]['image'] != null
                      ? Image.network(newsProvider.news[index]['image']!)
                      : null,
                  onTap: () {
                    final url = newsProvider.news[index]['link'];
                    if (url != null && url.isNotEmpty) {
                      _launchURL(url);
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
