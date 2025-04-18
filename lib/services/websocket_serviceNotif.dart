import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> connect(String userId) async {
    await initNotifications();
    
    if (_channel != null) {
      await _channel!.sink.close();
    }

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080?userId=$userId'),
    );

    _channel!.stream.listen(
      (message) => _handleMessage(message),
      onError: (error) => _reconnect(userId),
      onDone: () => _reconnect(userId),
    );
  }

  void _handleMessage(String message) {
    final data = jsonDecode(message);
    
    if (data['type'] == 'RESERVATION_STATUS_UPDATE') {
      _showNotification(
        title: 'Mise à jour de réservation',
        body: data['message'],
      );
    }
  }

  Future<void> _showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reservation_channel',
      'Mises à jour des réservations',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _reconnect(String userId) async {
    await Future.delayed(const Duration(seconds: 5));
    connect(userId);
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}