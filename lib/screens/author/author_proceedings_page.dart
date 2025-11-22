import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AuthorProceedingsPage extends StatefulWidget {
  const AuthorProceedingsPage({Key? key}) : super(key: key);

  @override
  State<AuthorProceedingsPage> createState() => _AuthorProceedingsPageState();
}

class _AuthorProceedingsPageState extends State<AuthorProceedingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có kỷ yếu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
