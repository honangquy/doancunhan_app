import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/constants.dart';
import 'chair_dashboard_screen.dart';
import 'chair_papers_screen.dart';
import 'chair_announcements_screen.dart';
import 'chair_profile_screen.dart';

class ChairMainScreen extends StatefulWidget {
  const ChairMainScreen({super.key});

  @override
  State<ChairMainScreen> createState() => _ChairMainScreenState();
}

class _ChairMainScreenState extends State<ChairMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChairDashboardScreen(), // Tổng quan
    const ChairPapersScreen(),    // Quản lý bài báo
    const ChairAnnouncementsScreen(), // Thông báo
    const ChairProfileScreen(),   // Profile & Đăng xuất
  ];

  final List<String> _titles = [
    'Tổng quan',
    'Bài báo',
    'Thông báo',
    'Cá nhân',
  ];

  final List<IconData> _icons = [
    CupertinoIcons.home,
    CupertinoIcons.doc_text,
    CupertinoIcons.bell,
    CupertinoIcons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => _buildNavItem(
                  index,
                  _icons[index],
                  _titles[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? primaryColor.withOpacity(0.1) 
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey[600],
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? primaryColor : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
