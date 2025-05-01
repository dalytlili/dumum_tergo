import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/views/seller/car/car-reservations-page.dart';
import 'package:dumum_tergo/views/user/car/reservation_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsUserPage extends StatefulWidget {
  final VoidCallback? onNotificationsRead;
  final VoidCallback? onBack;
  final ValueChanged<int>? onUnreadCountChanged;

  const NotificationsUserPage({
    Key? key,
    this.onNotificationsRead,
    this.onBack,
    this.onUnreadCountChanged,
  }) : super(key: key);

  @override
  State<NotificationsUserPage> createState() => _NotificationsUserPageState();
}

class _NotificationsUserPageState extends State<NotificationsUserPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;
  bool _hasNewNotifications = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadNotifications();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Charger plus de notifications si nécessaire
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? token = await storage.read(key: 'token');

      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:9098/api/notifications/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _notifications = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _hasNewNotifications = _notifications.any((n) => n['readAt'] == null);
          
          if (_hasNewNotifications && widget.onNotificationsRead != null) {
            widget.onNotificationsRead!();
          }

          if (widget.onUnreadCountChanged != null) {
            widget.onUnreadCountChanged!(_notifications.where((n) => n['readAt'] == null).length);
          }
        });
      } else {
        throw Exception('Erreur lors du chargement des notifications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des notifications...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Erreur: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              onPressed: _loadNotifications,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: Theme.of(context).primaryColor,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildNotificationItem(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final readStatus = notification['read'];
    final data = notification['data'] ?? {};
    final car = data['car'] ?? {};
    final user = data['user'] ?? {};
    final createdAt = notification['createdAt'] != null 
        ? DateTime.parse(notification['createdAt']) 
        : DateTime.now();

    final userImage = user['image'] != null
        ? "http://127.0.0.1:9098${user['image']}"
        : null;

    return InkWell(
      onTap: () async {
        try {
          String? token = await storage.read(key: 'token');
          if (token == null) throw Exception('Token non trouvé');

          // Marquer la notification comme lue si elle ne l'est pas déjà
          if (readStatus == false) {
            final response = await http.put(
              Uri.parse('http://127.0.0.1:9098/api/notifications/user/${notification['_id']}/read'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              setState(() {
                notification['read'] = true;
              });
            }
          }

          // Naviguer vers la page des réservations dans tous les cas
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationPage(authToken: token),
            ),
          );
        } catch (e) {
          print('Erreur lors du marquage de la notification comme lue: $e');
        }
      },

      child: Container(
        color: readStatus == false ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getNotificationColor(notification['type']).withOpacity(0.2),
              backgroundImage: userImage != null ? NetworkImage(userImage) : null,
              child: userImage == null
                  ? Icon(
                      _getNotificationIcon(notification['type']),
                      color: _getNotificationColor(notification['type']),
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getNotificationTitle(notification['type']),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: readStatus ? Colors.black : Colors.grey[700],
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (readStatus == false)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (user['name'] != null)
                    Text(
                      'De: ${user['name']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  if (car['brand'] != null && car['model'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${car['brand']} ${car['model']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (data['startDate'] != null && data['endDate'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        timeago.format(createdAt, locale: 'fr'),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'reservation_request':
        return Colors.blue;
      case 'reservation_accepted':
        return Colors.green;
      case 'reservation_rejected':
        return Colors.red;
      case 'payment_received':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'reservation_request':
        return Icons.car_rental;
      case 'reservation_accepted':
        return Icons.check_circle;
      case 'reservation_rejected':
        return Icons.cancel;
      case 'payment_received':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(String? type) {
    switch (type) {
      case 'reservation_request':
        return 'Nouvelle demande de réservation';
      case 'reservation_accepted':
        return 'Réservation confirmée';
      case 'reservation_rejected':
        return 'Réservation annulée';
      case 'payment_received':
        return 'Paiement reçu';
      default:
        return 'Notification';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  int _unreadNotifications = 0; // Nombre de notifications non lues

  final List<Widget> _screens = [
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  final List<String> _appBarTitles = [
    'Accueil',
    'Rechercher une voiture',
    'Marketplace',
    'Événement',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_currentIndex]),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  // Naviguer vers la page des notifications
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NotificationsUserPage(
                        onNotificationsRead: () {
                          setState(() {
                            _unreadNotifications = 0;
                          });
                        },
                        onUnreadCountChanged: (count) {
                          // Mettre à jour le badge dynamiquement
                          setState(() {
                            _unreadNotifications = count;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événement'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}