import 'package:example_radio2/radio_provider.dart';
import 'package:example_radio2/screens/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'news_provider.dart';
import 'news_detail_provider.dart'; // Import this line
import 'screens/home_screen.dart';
import 'screens/radio_screen1.dart';
import 'screens/radio_screen2.dart';
import 'screens/news_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyD1x-XXQdWY5mWv08JDMGUBfxnaFwckBEo",
        authDomain: "exampleradiosonv2.firebaseapp.com",
        projectId: "exampleradiosonv2",
        storageBucket: "exampleradiosonv2.appspot.com",
        messagingSenderId: "465204367533",
        appId: "1:465204367533:web:b253785fb5e98b55a5b624",
        measurementId: "G-440DEHSMR8"
    ),
  );

  if (await Permission.notification.request().isGranted) {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'radio_channel',
          channelName: 'Radio Notification',
          channelDescription: 'Bu kanal radyo bildirimleri için kullanılıyor',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
        ),
      ],
    );
  }
  NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => NewsDetailProvider()), // Add this line
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/radio1': (context) => RadioScreen1(),
          '/radio2': (context) => RadioScreen2(),
          '/news': (context) => NewsScreen(),
        },
      ),
    );
  }
}
