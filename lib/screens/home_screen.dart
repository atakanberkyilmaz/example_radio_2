import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showNotification();
              },
              child: Text('Show Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/news');
              },
              child: Text('Go to News'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/radio1');
              },
              child: Text('Go to Radio 1'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/radio2');
              },
              child: Text('Go to Radio 2'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'radio_channel',
        title: 'Test Bildirimi',
        body: 'Test bildiriminin içeriği...',
      ),
    );
  }
}
