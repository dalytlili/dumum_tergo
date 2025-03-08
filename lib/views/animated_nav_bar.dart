import 'package:dumum_tergo/constants/colors.dart';
import 'package:flutter/material.dart';

class AnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDarkMode;
  final List<Widget> screens; // Ajoutez cette propriété

  const AnimatedNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
    required this.screens, // Initialisez cette propriété
  }) : super(key: key);

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDarkMode ? Colors.grey[900]! : Colors.white;
    final Color selectedItemColor = widget.isDarkMode ? AppColors.primary : AppColors.primary;
    final Color unselectedItemColor = widget.isDarkMode ? Colors.grey[400]! : Colors.grey;
    final Color shadowColor = widget.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1);
    final Color iconBackgroundColor = widget.isDarkMode ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.2);

    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: widget.currentIndex,
            children: widget.screens, // Utilisez les écrans passés
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: backgroundColor,
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0,
              items: [
                _buildNavItem(Icons.home, "Home", 0, iconBackgroundColor, selectedItemColor, unselectedItemColor),
                _buildNavItem(Icons.search, "Search", 1, iconBackgroundColor, selectedItemColor, unselectedItemColor),
                _buildNavItem(Icons.favorite, "Likes", 2, iconBackgroundColor, selectedItemColor, unselectedItemColor),
                _buildNavItem(Icons.notifications, "Notifications", 3, iconBackgroundColor, selectedItemColor, unselectedItemColor),
                _buildNavItem(Icons.person, "Profile", 4, iconBackgroundColor, selectedItemColor, unselectedItemColor),
              ],
            ),
          ),
        ),
      ],
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
    bool isSelected = widget.currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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