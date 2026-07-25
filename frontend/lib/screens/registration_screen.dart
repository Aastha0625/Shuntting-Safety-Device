import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscurePassword = true;
  String? _selectedDesignation;

  final List<String> _designations = [
    'Loco Pilot',
    'Shunter',
    'Pointsman',
    'Yard Master',
    'Admin'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Join the Safety Network',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete your profile to access rail shunting operations and safety logs.',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // Form Fields
            const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'John Doe',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Employee ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'RS-10294',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Designation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Select position',
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
              value: _selectedDesignation,
              items: _designations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedDesignation = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            
            const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
            const SizedBox(height: 8),
            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
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
            const SizedBox(height: 16),
            
            const Text('Confirm Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.subtitleColor)),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
              ),
            ),
            const SizedBox(height: 24),
          
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                // Register action
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 24),
            
            const SizedBox(height: 16),
            
            // Footer
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
                    children: [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(text: 'Log in here.', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: const Text('System v2.4.1 | Server: Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
