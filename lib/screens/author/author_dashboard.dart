import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/announcement_provider.dart';
import 'author_home_page.dart';
import 'simple_papers_screen.dart';
import 'author_proceedings_page.dart';
import 'author_profile_page.dart';
import 'notifications_page.dart';

class AuthorDashboard extends StatefulWidget {
  const AuthorDashboard({Key? key}) : super(key: key);

  @override
  State<AuthorDashboard> createState() => _AuthorDashboardState();
}

class _AuthorDashboardState extends State<AuthorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AuthorHomePage(),
    const SimplePapersScreen(),
    const AuthorProceedingsPage(),
    const AuthorProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load unread count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tác giả'),
        backgroundColor: AppColors.authorPrimary,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<AnnouncementProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.unreadCount ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                      // Reload unread count after returning from notifications
                      if (mounted) {
                        context.read<AnnouncementProvider>().loadAnnouncements();
                      }
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
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
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.authorPrimary,
          unselectedItemColor: AppColors.textMedium,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Bài báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Kỷ yếu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}