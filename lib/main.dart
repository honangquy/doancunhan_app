import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Utils
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'utils/api_config.dart';
import 'utils/auth_error_handler.dart';

// Services
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/chair_service.dart';

// Providers
import 'providers/author_dashboard_provider.dart';
import 'providers/paper_detail_provider.dart';
import 'providers/chair_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_notification_provider.dart';
import 'providers/reviewer_provider.dart';

// Models
import 'models/paper.dart';
import 'models/notification.dart';

// Screens - Authentication
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/edit_profile_screen.dart';
import 'screens/auth/welcome_role_selection_screen.dart';
import 'screens/splash_screen.dart';

// Screens - Author
import 'screens/author/author_dashboard.dart';
import 'screens/author/author_home_page.dart';
import 'screens/author/submit_paper_page.dart';
import 'screens/author/my_papers_page.dart';
import 'screens/author/proceedings_page.dart';
import 'screens/author/notifications_page.dart';
import 'screens/author/author_profile_page.dart';
import 'screens/author/paper_detail_page.dart';

// Screens - Reviewer (Mới - Reviewer Mobile API)
import 'screens/reviewer/reviewer_dashboard.dart';
import 'screens/reviewer/reviewer_profile_page.dart';

// Screens - Admin
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_home_page.dart';
import 'screens/admin/admin_management_page.dart';
import 'screens/admin/admin_reports_page.dart';
import 'screens/admin/admin_profile_page.dart';
import 'screens/admin/assign_reviewer_page.dart';
import 'screens/admin/post_announcement_page.dart';
import 'screens/admin/track_process_page.dart';
import 'screens/admin/paper_management_page.dart';

// Screens - Chair (Admin features)
import 'screens/chair/chair_main_screen.dart';
import 'screens/chair/chair_dashboard_screen.dart';
import 'screens/chair/chair_papers_screen.dart';
import 'screens/chair/chair_paper_detail_screen.dart';
import 'screens/chair/chair_announcements_screen.dart';
import 'screens/chair/chair_profile_screen.dart';

// Screens - Notifications
import 'screens/notifications/notifications_screen.dart';
import 'screens/notifications/notification_detail_screen.dart';

// Screens - User Notifications (Broadcast)
import 'screens/user_notifications/user_notifications_list_screen.dart';
import 'screens/user_notifications/user_notification_detail_screen.dart';
import 'screens/user_notifications/create_broadcast_notification_screen.dart';

// Screens - Reviewer (New)
import 'screens/reviewer/reviewer_main_screen.dart';
import 'screens/reviewer/reviewer_dashboard_screen.dart';
import 'screens/reviewer/reviewer_assignments_screen.dart';
import 'screens/reviewer/reviewer_assignment_detail_screen.dart';
import 'screens/reviewer/reviewer_reviews_screen.dart';
import 'screens/reviewer/reviewer_review_form_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  try {
    // Initialize Storage Service first (other services depend on it)
    final storage = StorageService();
    await storage.init();
    debugPrint('✅ StorageService initialized');

    // Initialize API Service first (needed by Auth Service)
    final api = ApiService();
    await api.init();
    debugPrint('✅ ApiService initialized (Backend: ${ApiConfig.baseUrl})');

    // Initialize Auth Service (depends on Storage and API)
    final auth = AuthService();
    await auth.init();
    debugPrint('✅ AuthService initialized');
    debugPrint('   isAuthenticated: ${auth.isAuthenticated}');
    debugPrint('   userRole: ${auth.userRole}');

  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
  }

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        
        // Providers
        ChangeNotifierProvider(create: (_) => AuthorDashboardProvider()),
        ChangeNotifierProvider(create: (_) => PaperDetailProvider()),
        ChangeNotifierProvider(create: (_) => ChairProvider(ChairService())),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewerProvider()),
      ],
      child: MaterialApp(
        // App Info
        title: 'HUIT Conference',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Initial Route
        initialRoute: '/',
        
        // Route Generator
        onGenerateRoute: _onGenerateRoute,

        // Unknown Route Handler
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const _NotFoundScreen(),
          );
        },

        // Builder for global error handling and set auth context
        builder: (context, child) {
          // Set context for auth error handler to auto-logout on 401
          AuthErrorHandler().setContext(context);
          
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    debugPrint('📍 Navigating to: ${settings.name}');

    switch (settings.name) {
      // ========== Splash & Initial ==========
      case '/':
        return _buildRoute(const SplashScreen());

      // ========== Authentication ==========
      case '/login':
        return _buildRoute(const LoginScreen());
      
      case '/welcome':
        return _buildRoute(const WelcomeRoleSelectionScreen());

      case '/register':
        return _buildRoute(const RegisterScreen());

      case '/forgot-password':
        return _buildRoute(const ForgotPasswordScreen());

      case '/reset-password':
        return _buildRoute(const ResetPasswordScreen());

      case '/edit-profile':
        return _buildRoute(const EditProfileScreen());

      // ========== Author Routes ==========
      case '/author/dashboard':
        return _buildRoute(const AuthorDashboard());

      case '/author/home':
        return _buildRoute(const AuthorHomePage());

      case '/author/submit':
        return _buildRoute(const SubmitPaperPage());

      case '/author/papers':
        return _buildRoute(const MyPapersPage());

      case '/author/proceedings':
        return _buildRoute(const ProceedingsPage());

      case '/author/notifications':
        return _buildRoute(const NotificationsPage());

      case '/author/profile':
        return _buildRoute(const AuthorProfilePage());

      case '/author/paper-detail':
        if (settings.arguments is Paper) {
          return _buildRoute(
            PaperDetailPage(paper: settings.arguments as Paper),
          );
        }
        return _buildErrorRoute('Paper data required');

      // ========== Reviewer Routes ==========
      case '/reviewer/dashboard':
        return _buildRoute(const ReviewerDashboard());

      case '/reviewer/profile':
        return _buildRoute(const ReviewerProfilePage());

      // Các route Reviewer cũ đã bị xóa - chuyển về dashboard
      case '/reviewer/home':
      case '/reviewer/assigned':
      case '/reviewer/history':
      case '/reviewer/paper':
      case '/reviewer/review':
        return _buildRoute(const ReviewerDashboard());

      // ========== Admin Routes (redirect to Chair) ==========
      case '/admin/dashboard':
        return _buildRoute(const AdminDashboard());

      // ========== Chair Routes ==========
      case '/chair/dashboard':
        return _buildRoute(const ChairMainScreen());

      case '/chair/papers':
        return _buildRoute(const ChairPapersScreen());

      case '/chair/home':
        return _buildRoute(const AdminHomePage());

      case '/chair/management':
        return _buildRoute(const AdminManagementPage());

      case '/chair/reports':
        return _buildRoute(const AdminReportsPage());

      case '/chair/profile':
        return _buildRoute(const AdminProfilePage());

      case '/chair/assign-reviewer':
        return _buildRoute(const AssignReviewerPage());

      case '/chair/post-announcement':
        return _buildRoute(const PostAnnouncementPage());

      case '/chair/track-process':
        return _buildRoute(const TrackProcessPage());

      case '/chair/paper-management':
        return _buildRoute(const PaperManagementPage());

      // ========== User Notifications (Broadcast) Routes ==========
      case '/user-notifications':
        return _buildRoute(const UserNotificationsListScreen());

      case '/user-notifications/detail':
        if (settings.arguments is int) {
          return _buildRoute(
            UserNotificationDetailScreen(notificationId: settings.arguments as int),
          );
        }
        return _buildErrorRoute('Notification ID required');

      case '/user-notifications/create':
        return _buildRoute(const CreateBroadcastNotificationScreen());

      // ========== Reviewer Routes (New Mobile API) ==========
      case '/reviewer/main':
        return _buildRoute(const ReviewerMainScreen());

      case '/reviewer/assignments':
        return _buildRoute(const ReviewerAssignmentsScreen());

      case '/reviewer/assignment-detail':
        if (settings.arguments is int) {
          return _buildRoute(
            ReviewerAssignmentDetailScreen(assignmentId: settings.arguments as int),
          );
        }
        return _buildErrorRoute('Assignment ID required');

      case '/reviewer/reviews':
        return _buildRoute(const ReviewerReviewsScreen());

      case '/reviewer/review-form':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            ReviewerReviewFormScreen(
              assignmentId: args['assignmentId'] as int,
              existingReview: args['existingReview'],
            ),
          );
        }
        return _buildErrorRoute('Assignment data required');

      // ========== Notifications Routes (Old system) ==========
      case '/notifications':
        return _buildRoute(const NotificationsScreen());

      case '/notifications/detail':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final notificationId = args['id'] as int;
          return _buildRoute(
            _NotificationDetailWrapper(notificationId: notificationId),
          );
        }
        return _buildErrorRoute('Notification data required');

      // ========== Default ==========
      default:
        return null;
    }
  }

  // Build standard route with slide transition
  MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(
      builder: (context) => page,
    );
  }

  // Build route with custom transition (currently unused but kept for future use)
  // ignore: unused_element
  PageRouteBuilder _buildCustomRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Build error route
  MaterialPageRoute _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => _ErrorScreen(message: message),
    );
  }
}

// ========== Helper Screens ==========

/// Splash Screen with initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication
    final auth = AuthService();
    
    if (auth.isAuthenticated) {
      // User is logged in, navigate to dashboard based on role
      _navigateByRole(auth.userRole);
    } else {
      // User not logged in - go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateByRole(String? role) {
    String route = '/login';
    
    switch (role?.toLowerCase()) {
      case 'admin':
      case 'chair':
        route = '/chair/dashboard';
        break;
      case 'reviewer':
        route = '/reviewer/dashboard';
        break;
      case 'author':
        route = '/author/dashboard';
        break;
      default:
        route = '/login';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            const Text(
              'HUIT Conference',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Conference Management System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Not Found Screen (404)
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error Screen for invalid arguments
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper to load notification by ID and display detail screen
class _NotificationDetailWrapper extends StatelessWidget {
  final int notificationId;

  const _NotificationDetailWrapper({
    Key? key,
    required this.notificationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppNotification?>(
      future: Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotificationById(notificationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const _ErrorScreen(
            message: 'Không thể tải thông báo',
          );
        }

        return NotificationDetailScreen(
          notification: snapshot.data!,
        );
      },
    );
  }
}