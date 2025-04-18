import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  StreamSubscription? _socketSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final _notificationsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _notifications = [];
  String? _userId;

  Stream<List<Map<String, dynamic>>> get notificationsStream => _notificationsController.stream;

  Future<void> initialize() async {
    await _initAudioPlayer();
    await _initNotifications();
    await _initializeWebSocket();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print("Erreur d'initialisation audio: $e");
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Erreur de lecture audio: $e');
    }
  }

  Future<void> _initNotifications() async {
    if (Platform.isIOS) {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    }
    
    if (Platform.isAndroid) {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel(
          'notifications_channel',
          'Notifications',
          description: 'Notifications en temps réel',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
      );
    }

    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      ),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification cliquée: ${response.payload}');
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    await _playNotificationSound();
    
    if (Platform.isIOS) {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: 'notification_payload',
      );
    } else {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'notifications_channel',
            'Notifications',
            channelDescription: 'Notifications en temps réel',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: 'notification_payload',
      );
    }
  }

  Future<void> _initializeWebSocket() async {
    try {
      final token = await _storage.read(key: 'seller_token');
      if (token == null) {
        print('Aucun token trouvé');
        return;
      }

      final vendorId = await _getUserIdFromToken(token);
      if (vendorId == null) {
        print('Impossible d\'extraire l\'ID utilisateur du token');
        return;
      }

      _userId = vendorId;
      await _connectToWebSocket(vendorId);
    } catch (e) {
      print('Erreur d\'initialisation WebSocket: $e');
    }
  }

  Future<String?> _getUserIdFromToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonMap = jsonDecode(decoded);

      return jsonMap['vendorId']?.toString() ?? 
             jsonMap['userId']?.toString() ?? 
             jsonMap['id']?.toString();
    } catch (e) {
      print('Erreur de décodage du token: $e');
      return null;
    }
  }

  Future<void> _connectToWebSocket(String userId) async {
    try {
      const String serverIp = '127.0.0.1';
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$serverIp:8084?userId=$userId'),
      );

      _socketSubscription = _channel!.stream.listen(
        (message) => _handleSocketMessage(message),
        onError: (error) {
          print('WebSocket error: $error');
          _reconnectWebSocket(userId);
        },
        onDone: () {
          print('WebSocket fermé');
          _reconnectWebSocket(userId);
        },
      );

    } catch (e) {
      print('Erreur de connexion WebSocket: $e');
      _reconnectWebSocket(userId);
    }
  }

  void _reconnectWebSocket(String userId) {
    Future.delayed(const Duration(seconds: 5), () {
      _connectToWebSocket(userId);
    });
  }

  void _handleSocketMessage(String message) {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      
      if (data['type'] == 'notification') {
        _handleNewNotification(data['data']);
      } 
      else if (data['type'] == 'notifications') {
        _handleExistingNotifications(data['data']);
      }
      
    } catch (e) {
      print('Erreur de traitement du message: $e');
    }
  }

  void _handleNewNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
    
    // Afficher la notification système
    final title = _getNotificationTitle(notification);
    final body = _getNotificationBody(notification);
    _showNotification(title, body);
  }

  void _handleExistingNotifications(List<dynamic> notifications) {
    _notifications = notifications.map((n) => n as Map<String, dynamic>).toList();
    _notificationsController.add(_notifications);
    
    // Afficher une notification pour les notifications non lues
    if (notifications.isNotEmpty) {
      final notification = notifications[0] as Map<String, dynamic>;
      final title = _getNotificationTitle(notification);
      final body = _getNotificationBody(notification);
      _showNotification(title, body);
    }
  }

  String _getNotificationTitle(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'reservation':
        return 'Nouvelle réservation';
      case 'cancellation':
        return 'Annulation de réservation';
      case 'update':
        return 'Mise à jour';
      default:
        return 'Nouvelle notification';
    }
  }

  String _getNotificationBody(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>;
    switch (notification['type']) {
      case 'reservation':
        return 'Nouvelle réservation reçue pour ${data['carBrand']} ${data['carModel']}';
      case 'cancellation':
        return 'Réservation annulée pour ${data['carBrand']} ${data['carModel']}';
      case 'update':
        return 'Mise à jour de votre réservation';
      default:
        return notification['message'] ?? 'Nouvelle notification reçue';
    }
  }

  void dispose() {
    _socketSubscription?.cancel();
    _channel?.sink.close();
    _audioPlayer.dispose();
    _notificationsController.close();
  }
} 