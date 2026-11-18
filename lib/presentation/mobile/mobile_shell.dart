import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../mobile/screens/mobile_category_screen.dart';
import '../mobile/screens/mobile_home_screen.dart';
import '../mobile/screens/mobile_live_tv_screen.dart';
import '../mobile/screens/mobile_search_screen.dart';
import '../mobile/screens/mobile_youtube_screen.dart';

class MobileShell extends StatefulWidget {
  final int initialIndex;
  const MobileShell({super.key, this.initialIndex = 0});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    MobileHomeScreen(),
    MobileCategoryScreen(),
    MobileLiveTvScreen(),
    MobileYoutubeScreen(),
    MobileSearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textLight,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category_rounded),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv_outlined),
                  activeIcon: Icon(Icons.live_tv_rounded),
                  label: 'Live TV',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_display_outlined),
                  activeIcon: Icon(Icons.smart_display_rounded),
                  label: 'YouTube',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.manage_search_rounded),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
