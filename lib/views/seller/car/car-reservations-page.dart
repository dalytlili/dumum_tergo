import 'package:dumum_tergo/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reservation_detail_page.dart'; // Importez votre nouvelle page
import 'notifications_page.dart'; // Importez la nouvelle page de notifications
import 'package:dumum_tergo/services/notification_service.dart';

class CarReservationsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onReservationSelected;
  final String? initialReservationId; // Nouveau paramètre

  const CarReservationsPage({Key? key, required this.onReservationSelected,this.initialReservationId,}) : super(key: key);

  @override
  _CarReservationsPageState createState() => _CarReservationsPageState();
}

class _CarReservationsPageState extends State<CarReservationsPage> {
  final storage = const FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();
  List<dynamic> reservations = [];
  List<dynamic> filteredReservations = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  String selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  Widget? _overlayContent;
  int _unreadNotifications = 0;

  final List<String> statusOptions = [
    'all',
    'pending',
    'accepted',
    'completed',
    'rejected',
    'cancelled'
  ];

  @override
   void initState() {
    super.initState();
    _fetchReservations().then((_) {
      // Après le chargement, si on a un ID initial, on filtre et on navigue
      if (widget.initialReservationId != null) {
        _navigateToInitialReservation();
      }
    });
    _initializeNotifications();
  }
void _navigateToInitialReservation() {
    final initialReservation = reservations.firstWhere(
      (r) => r['_id'] == widget.initialReservationId,
      orElse: () => null,
    );
    
    if (initialReservation != null) {
      // Appliquer le filtre
      setState(() {
        selectedStatus = 'all';
        searchQuery = initialReservation['car']['brand'] + ' ' + initialReservation['car']['model'];
        _filterReservations();
      });
      
      // Naviguer vers les détails après un petit délai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onReservationSelected(initialReservation);
      });
    }
  }
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    _notificationService.notificationsStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _unreadNotifications = notifications.where((n) => !n['read']).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReservations() {
    setState(() {
      filteredReservations = reservations.where((reservation) {
        final matchesSearch = searchQuery.isEmpty ||
            reservation['car']['brand'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            reservation['car']['model'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            reservation['driverDetails']['firstName'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            reservation['driverDetails']['lastName'].toString().toLowerCase().contains(searchQuery.toLowerCase());

        final matchesStatus = selectedStatus == 'all' || reservation['status'] == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _fetchReservations() async {
    try {
      final token = await storage.read(key: 'seller_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:9098/api/reservation/vendor'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reservations = data;
          filteredReservations = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _overlayContent == null ? AppBar(
        title: const Text('Liste des réservations'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  setState(() {
                    _overlayContent = NotificationsPage(
                      onNotificationsRead: () {
                        setState(() {
                          _unreadNotifications = 0;
                        });
                      },
                      onBack: () {
                        setState(() {
                          _overlayContent = null;
                        });
                      },
                    );
                  });
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 23,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      _unreadNotifications.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ) : null,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une réservation...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        _filterReservations();
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: statusOptions.map((status) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                status == 'all' ? 'Tous' : status.toUpperCase(),
                                style: TextStyle(
                                  color: selectedStatus == status ? Colors.white : Colors.black87,
                                ),
                              ),
                              selected: selectedStatus == status,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedStatus = status;
                                });
                                _filterReservations();
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppColors.primary,
                              checkmarkColor: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: _buildReservationsList(),
                ),
              ),
            ],
          ),
          if (_overlayContent != null)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: _overlayContent,
            ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            Text(errorMessage!),
          ],
        ),
      );
    } else if (filteredReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_rental, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || selectedStatus != 'all'
                  ? 'Aucune réservation ne correspond à vos critères'
                  : 'Aucune réservation trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _fetchReservations,
        color: AppColors.primary,
        child: ListView.builder(
          itemCount: filteredReservations.length,
          itemBuilder: (context, index) {
            final reservation = filteredReservations[index];
            return _buildReservationCard(context, reservation);
          },
        ),
      );
    }
  }

  Widget _buildReservationCard(BuildContext context, dynamic reservation) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final startDate = dateFormat.format(DateTime.parse(reservation['startDate']));
    final endDate = dateFormat.format(DateTime.parse(reservation['endDate']));
    final createdAt = DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(reservation['createdAt']));

    return GestureDetector(
      onTap: () {
        widget.onReservationSelected(reservation);
      },
      child: Card(
        color: Colors.white, // Couleur de la carte en blanc
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2, // Ombre plus légère
        shadowColor: Colors.grey.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: reservation['car']['images'] != null && reservation['car']['images'].isNotEmpty
                        ? Image.network(
                            'http://127.0.0.1:9098/images/${reservation['car']['images'][0]}',
                            width: 90,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 90,
                              height: 70,
                              color: Colors.grey[100],
                              child: const Icon(Icons.car_rental, size: 40, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 90,
                            height: 70,
                            color: Colors.grey[100],
                            child: const Icon(Icons.car_rental, size: 40, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reservation['car']['brand']} ${reservation['car']['model']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                         const SizedBox(height: 4),
                        Text(
                          '${reservation['car']['registrationNumber']} ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reservation['driverDetails']['firstName']} ${reservation['driverDetails']['lastName']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(reservation['status']),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 12),
           SizedBox(
  height: 50, // ou la hauteur de ton item
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
      _buildInfoItem(Icons.calendar_today, '$startDate - $endDate'),
      SizedBox(width: 16),
      _buildInfoItem(Icons.location_on, reservation['location']),
      SizedBox(width: 16),
      _buildInfoItem(Icons.euro, '${reservation['totalPrice']} / DTN'),
    ],
  ),
),

              const SizedBox(height: 2),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Créé le: $createdAt',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    onPressed: () {
                      widget.onReservationSelected(reservation);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        break;
          case 'accepted':
      case 'completed':
        chipColor = Colors.green;
        break;
       case 'rejected':
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}