import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/yard_setup_screen.dart';
import '../screens/device_inventory_screen.dart';
import '../screens/de_assignment_screen.dart';
import '../screens/issue_return_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2A42), Color(0xFF0F172A)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.train, color: Colors.white, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'SafeShunt Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configuration & Setup',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryColor),
            title: const Text('Home (Dashboard)', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.popUntil(context, (route) => route.isFirst); // Go back to root
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.account_tree_outlined,
            title: 'Yard & Line Setup',
            destination: const YardSetupScreen(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Device Inventory',
            destination: const DeviceInventoryScreen(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.linear_scale,
            title: 'DE Line Assignments',
            destination: const DEAssignmentScreen(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Issue & Return',
            destination: const IssueReturnScreen(),
          ),
          const Divider(color: AppTheme.borderColor),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppTheme.subtitleColor),
            title: const Text('Settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings (Coming Soon)')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
