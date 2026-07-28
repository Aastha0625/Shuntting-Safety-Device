import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_session.dart';
import '../screens/yard_setup_screen.dart';
import '../screens/device_inventory_screen.dart';
import '../screens/de_assignment_screen.dart';
import '../screens/issue_return_screen.dart';
import '../screens/user_management_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();

    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with user info and role
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2A42), Color(0xFF0F172A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Text(
                        (session.fullName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.fullName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.employeeId ?? '',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleBadgeColor(session.role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.displayRole,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                // Show assigned yards for Yard Admin
                if (session.isYardAdmin && session.assignedYards.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Yards: ${session.assignedYardNames.join(", ")}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (session.isYardAdmin && session.assignedYards.isEmpty) ...[
                  const SizedBox(height: 6),
                  const Text(
                    '⚠ No yards assigned',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          // Home / Dashboard - visible to all
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryColor),
            title: const Text('Home (Dashboard)', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),

          // Yard & Line Setup - Super Admin only
          if (session.canConfigureYards)
            _buildDrawerItem(
              context: context,
              icon: Icons.account_tree_outlined,
              title: 'Yard & Line Setup',
              destination: const YardSetupScreen(),
            ),

          // Device Inventory - Super Admin and Yard Admin
          if (session.canManageDevices)
            _buildDrawerItem(
              context: context,
              icon: Icons.inventory_2_outlined,
              title: 'Device Inventory',
              destination: const DeviceInventoryScreen(),
            ),

          // DE Line Assignments - Super Admin and Yard Admin
          if (session.canManageDevices)
            _buildDrawerItem(
              context: context,
              icon: Icons.linear_scale,
              title: 'DE Line Assignments',
              destination: const DEAssignmentScreen(),
            ),

          // Issue & Return - Super Admin and Yard Admin
          if (session.canIssueReturn)
            _buildDrawerItem(
              context: context,
              icon: Icons.swap_horiz,
              title: 'Issue & Return',
              destination: const IssueReturnScreen(),
            ),

          // User Management - Super Admin only
          if (session.canManageUsers) ...[
            const Divider(color: AppTheme.borderColor),
            _buildDrawerItem(
              context: context,
              icon: Icons.admin_panel_settings_outlined,
              title: 'User Management',
              destination: const UserManagementScreen(),
            ),
          ],

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

  Color _getRoleBadgeColor(String? role) {
    switch (role) {
      case UserSession.roleSuperAdmin:
        return const Color(0xFFDC2626); // Red for super admin
      case UserSession.roleYardAdmin:
        return const Color(0xFF2563EB); // Blue for yard admin
      case UserSession.roleMaintenanceUser:
        return const Color(0xFFD97706); // Amber for maintenance
      case UserSession.roleViewer:
        return const Color(0xFF059669); // Green for viewer
      default:
        return AppTheme.subtitleColor;
    }
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
