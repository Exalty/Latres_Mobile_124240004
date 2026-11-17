import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi service notifikasi
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Callback ketika notifikasi diklik
      },
    );

    // Buat Notification Channel untuk Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tv_series_channel',
      'Pengingat Serial TV & Watchlist',
      description: 'Notifikasi untuk jadwal tayang film dan status favorit',
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Request izin notifikasi (wajib untuk Android 13+)
  static Future<bool?> requestPermission() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission();
    }
    return true;
  }

  /// Tampilkan notifikasi instan
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tv_series_channel',
      'Pengingat Serial TV & Watchlist',
      channelDescription: 'Notifikasi untuk jadwal tayang film dan status favorit',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  /// Jadwalkan notifikasi setelah sekian detik
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int secondsFromNow,
  }) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow));

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tv_series_channel',
      'Pengingat Serial TV & Watchlist',
      channelDescription: 'Notifikasi untuk jadwal tayang film dan status favorit',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
