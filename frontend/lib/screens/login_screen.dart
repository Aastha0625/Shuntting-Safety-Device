import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.directions_railway, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Railway Safety'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.borderColor, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Logo Icon Placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Shunting Safety',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Secure Personnel Authentication',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // Login Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Employee ID / Username', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter your ID',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Login action
                    },
                    child: const Text('LOGIN'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Forgot Password
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text('Need an account? Register', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('System v2.4.1', style: TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('|', style: TextStyle(color: AppTheme.borderColor)),
                ),
                Text('App Version 1.0', style: TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
