// core/services/fcm_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init({
    required Future<void> Function(String token) onToken,
    required void Function(RemoteMessage) onTap,
  }) async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const channel = AndroidNotificationChannel(
      'waste_channel',
      'Thông báo phân loại rác',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Token
    final token = await _fcm.getToken();
    if (token != null) await onToken(token);
    _fcm.onTokenRefresh.listen(onToken);

    // Foreground: tự hiển thị bằng local notification
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _local.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    // Bấm thông báo khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);

    // Bấm thông báo khi app đã bị tắt hẳn
    final initial = await _fcm.getInitialMessage();
    if (initial != null) onTap(initial);
  }
}
