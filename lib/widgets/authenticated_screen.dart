import 'package:flutter/material.dart';
import '../utils/auth_checker.dart';

/// Widget wrapper để tự động check authentication
/// Sử dụng cho các màn hình cần authentication
class AuthenticatedScreen extends StatefulWidget {
  final Widget child;
  final bool checkOnInit;
  
  const AuthenticatedScreen({
    super.key,
    required this.child,
    this.checkOnInit = true,
  });
  
  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  bool _isChecking = true;
  
  @override
  void initState() {
    super.initState();
    if (widget.checkOnInit) {
      _checkAuth();
    } else {
      _isChecking = false;
    }
  }
  
  Future<void> _checkAuth() async {
    await AuthChecker.checkAuthAndRedirectIfNeeded(context);
    
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}
