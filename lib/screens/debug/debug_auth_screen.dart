import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/api_config.dart';

/// Debug screen để kiểm tra token và auth state
class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  String? _token;
  String? _user;
  String? _appUser;
  String? _roles;
  String? _currentRole;
  
  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }
  
  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _token = prefs.getString(ApiConfig.tokenKey);
      _user = prefs.getString(ApiConfig.userKey);
      _appUser = prefs.getString('app_user');
      _roles = prefs.getString('user_roles');
      _currentRole = prefs.getString('current_role');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Token',
            _token != null 
                ? '${_token!.substring(0, 50)}...\n\nLength: ${_token!.length}'
                : 'NULL',
            _token != null ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'User',
            _user ?? 'NULL',
            _user != null ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'App User',
            _appUser ?? 'NULL',
            _appUser != null ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Roles',
            _roles ?? 'NULL',
            _roles != null ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Current Role',
            _currentRole ?? 'NULL',
            _currentRole != null ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAuthData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _clearAllData,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear All Auth Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, String content, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  color == Colors.green ? Icons.check_circle : Icons.error,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Xóa toàn bộ dữ liệu auth?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _loadAuthData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã xóa toàn bộ dữ liệu'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
