import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../services/user_session.dart';
import 'login_screen.dart';
import 'dart:math' as math;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A2A42), Color(0xFF0F172A)], // Rich deep blue gradient
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Live Operations', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.redAccent),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Screen (Coming Soon)')),
                );
              } else if (value == 'logout') {
                UserSession().clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('View Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildRoleBanner(),
            _buildCriticalAlertsBanner(),
            const SizedBox(height: 24),
            _buildSectionTitle('LIVE ACTIVE SESSIONS', Icons.radar),
            _buildLiveSessionsCarousel(),
            const SizedBox(height: 32),
            _buildSectionTitle('YARD HEALTH SUMMARY', Icons.health_and_safety_outlined),
            _buildHealthSummaryGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.subtitleColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppTheme.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBanner() {
    final session = UserSession();

    // Show a contextual banner for Yard Admins
    if (session.isYardAdmin) {
      final yardNames = session.assignedYardNames;
      final hasYards = yardNames.isNotEmpty;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasYards
                ? [const Color(0xFF1E3A5F), const Color(0xFF16325B)]
                : [Colors.orange.shade700, Colors.orange.shade900],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                hasYards ? Icons.location_city : Icons.warning_amber_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasYards ? 'Yard Administrator' : 'No Yards Assigned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasYards
                          ? 'Viewing: ${yardNames.join(", ")}'
                          : 'Contact Super Administrator to assign yards.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Super Admin sees a brief summary
    if (session.isSuperAdmin) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
        ),
        child: Row(
          children: const [
            Icon(Icons.admin_panel_settings, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Super Administrator – Viewing All Yards',
              style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    // Other roles: no special banner
    return const SizedBox.shrink();
  }

  Widget _buildCriticalAlertsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1 Critical Alert',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Device DE-042 missed heartbeat (30m+ offline)',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSessionsCarousel() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildLiveGlowingCard(
            yard: 'North Yard',
            line: 'Line 4',
            ldDevice: 'LD-001',
            deDevice: 'DE-012',
            distance: '1.2m',
            isClosing: true,
          ),
          _buildLiveGlowingCard(
            yard: 'South Yard',
            line: 'Line 2',
            ldDevice: 'LD-014',
            deDevice: 'DE-008',
            distance: '24.5m',
            isClosing: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGlowingCard({
    required String yard,
    required String line,
    required String ldDevice,
    required String deDevice,
    required String distance,
    required bool isClosing,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isClosing ? Colors.greenAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isClosing ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.radar,
              size: 100,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$yard • $line',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('LIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pairing', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '$ldDevice ↔ $deDevice',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isClosing ? 'Closing In' : 'Approaching',
                          style: TextStyle(
                            color: isClosing ? Colors.greenAccent : Colors.blueAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummaryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHealthCard('Total Active\nDevices', '42', Icons.memory, Colors.blue),
          _buildHealthCard('Devices\nOffline', '2', Icons.wifi_off, Colors.red),
          _buildHealthCard('Total Sessions\nToday', '18', Icons.history, Colors.purple),
          _buildHealthCard('System\nStatus', '98%', Icons.check_circle_outline, Colors.green),
        ],
      ),
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
