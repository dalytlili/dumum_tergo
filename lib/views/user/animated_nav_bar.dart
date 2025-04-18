import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/viewmodels/user/HomeViewModel.dart';
import 'package:dumum_tergo/views/user/item/camping_items_screen.dart';
import 'package:dumum_tergo/views/user/notifications_page.dart';
import 'package:dumum_tergo/views/user/rental_search_view.dart';
import 'package:dumum_tergo/views/user/side_menu_view.dart';
import 'package:dumum_tergo/views/user/profile_view.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service_user.dart';
import 'dart:async';

class AnimatedNavBar extends StatefulWidget {
  final bool isDarkMode;

  const AnimatedNavBar({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> {
  int _currentIndex = 0;
  int _unreadNotifications = 0;
  late StreamSubscription _notificationSubscription;
  final NotificationServiceuser _notificationService = NotificationServiceuser();

  final List<Widget> _screens = [
    const HomeView(), // Remplacez Placeholder par votre vrai écran d'accueil
    const RentalSearchView(),
    const CampingItemsScreen(),
    const Placeholder(), // Écran Événement
    ProfileView(),
  ];

  final List<String> _appBarTitles = [
    'Accueil',
    'Rechercher une voiture',
    'Marketplace',
    'Événement',
    'Profil',
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    
    _notificationSubscription = _notificationService.notificationsStream.listen((notifications) {
      final unreadCount = notifications.where((n) => n['read'] == false).length;
      
      if (mounted) {
        setState(() {
          _unreadNotifications = unreadCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDarkMode ? Colors.grey[900]! : Colors.white;
    final Color selectedItemColor = widget.isDarkMode ? AppColors.primary : AppColors.primary;
    final Color unselectedItemColor = widget.isDarkMode ? Colors.grey[400]! : Colors.grey;
    final Color shadowColor = widget.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1);
    final Color iconBackgroundColor = widget.isDarkMode ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_currentIndex]),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NotificationsUserPage(
                        onNotificationsRead: () {
                          setState(() {
                            _unreadNotifications = 0;
                          });
                        },
                      ),
                    ),
                  );
                  
                  if (result != null && result is int) {
                    setState(() {
                      _unreadNotifications = result;
                    });
                  }
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
                      _unreadNotifications > 9 ? '9+' : _unreadNotifications.toString(),
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
      drawer: const SideMenuView(),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: backgroundColor,
            selectedItemColor: selectedItemColor,
            unselectedItemColor: unselectedItemColor,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              _buildNavItem(Icons.home, "Home", 0, iconBackgroundColor, selectedItemColor, unselectedItemColor),
              _buildNavItem(Icons.directions_car, "Chercher voiture", 1, iconBackgroundColor, selectedItemColor, unselectedItemColor),
              _buildNavItem(Icons.storefront, "Marketplace", 2, iconBackgroundColor, selectedItemColor, unselectedItemColor),
              _buildNavItem(Icons.local_fire_department, "Événement Camping", 3, iconBackgroundColor, selectedItemColor, unselectedItemColor),
              _buildNavItem(Icons.person, "Profile", 4, iconBackgroundColor, selectedItemColor, unselectedItemColor),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color iconBackgroundColor,
    Color selectedItemColor,
    Color unselectedItemColor,
  ) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? iconBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: isSelected ? 30 : 26,
          color: isSelected ? selectedItemColor : unselectedItemColor,
        ),
      ),
      label: label,
    );
  }
}