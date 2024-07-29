import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../radio_provider.dart';

class NotificationService {
  static void initialize() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final context = MyApp.navigatorKey.currentState?.context;
      if (context != null) {
        final radioProvider = context.read<RadioProvider>();
        if (receivedAction.buttonKeyPressed == 'PREVIOUS') {
          radioProvider.previousRadio();
        } else if (receivedAction.buttonKeyPressed == 'PLAY_PAUSE') {
          radioProvider.togglePlayPause();
        } else if (receivedAction.buttonKeyPressed == 'NEXT') {
          radioProvider.nextRadio();
        }
      }
    });
  }
}
