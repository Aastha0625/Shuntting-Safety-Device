import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../services/user_session.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();

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
        shadowColor: Colors.black.withValues(alpha: 0.5),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
      body: _buildBodyForRole(session),
    );
  }

  Widget _buildBodyForRole(UserSession session) {
    if (session.isSuperAdmin) {
      return _buildSuperAdminBody();
    } else if (session.isYardAdmin) {
      return _buildYardAdminBody(session);
    } else {
      return _buildViewerBody();
    }
  }

  // ==========================================
  // SUPER ADMIN DASHBOARD
  // ==========================================
  Widget _buildSuperAdminBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSuperAdminBanner(),
          _buildCriticalAlertsBanner(),
          const SizedBox(height: 24),
          _buildSectionTitle('LIVE ACTIVE SESSIONS', Icons.radar),
          _buildLiveSessionsCarousel(),
          const SizedBox(height: 16),
          _buildSectionTitle('GLOBAL YARD HEALTH SUMMARY', Icons.health_and_safety_outlined),
          _buildHealthSummaryGrid(title1: 'Total Active\nDevices', title2: 'Devices\nOffline', title3: 'Total Sessions\nToday', title4: 'System\nStatus'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // YARD ADMIN DASHBOARD
  // ==========================================
  Widget _buildYardAdminBody(UserSession session) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildYardAdminBanner(session),
          _buildYardAdminQuickActions(),
          _buildCriticalAlertsBanner(), // Filtered implicitly by backend in future
          const SizedBox(height: 24),
          _buildSectionTitle('LIVE ACTIVE SESSIONS (MY YARDS)', Icons.radar),
          _buildLiveSessionsCarousel(),
          const SizedBox(height: 16),
          _buildSectionTitle('MY YARDS HEALTH SUMMARY', Icons.health_and_safety_outlined),
          _buildHealthSummaryGrid(title1: 'Active Devices\n(My Yards)', title2: 'Devices Offline\n(My Yards)', title3: 'My Sessions\nToday', title4: 'My Yards\nStatus'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // VIEWER / CONTROL ROOM DASHBOARD
  // ==========================================
  Widget _buildViewerBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildCriticalAlertsBanner(),
          const SizedBox(height: 16),
          _buildSectionTitle('LIVE OPERATIONS FEED', Icons.radar),
          // Expanded vertical list instead of horizontal carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildLiveGlowingCard(
                  yard: 'North Yard',
                  line: 'Line 4',
                  ldDevice: 'LD-001',
                  deDevice: 'DE-012',
                  distance: '1.2m',
                  isClosing: true,
                  isExpanded: true,
                ),
                _buildLiveGlowingCard(
                  yard: 'South Yard',
                  line: 'Line 2',
                  ldDevice: 'LD-014',
                  deDevice: 'DE-008',
                  distance: '24.5m',
                  isClosing: false,
                  isExpanded: true,
                ),
                _buildLiveGlowingCard(
                  yard: 'North Yard',
                  line: 'Line 1',
                  ldDevice: 'LD-005',
                  deDevice: 'DE-022',
                  distance: '45.0m',
                  isClosing: false,
                  isExpanded: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // COMMON WIDGETS
  // ==========================================

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

  Widget _buildSuperAdminBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
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

  Widget _buildYardAdminBanner(UserSession session) {
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

  Widget _buildYardAdminQuickActions() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue Device workflow coming soon')));
                },
                icon: const Icon(Icons.output, size: 16, color: Colors.white),
                label: const Text('Issue', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return Device workflow coming soon')));
                },
                icon: const Icon(Icons.keyboard_return, size: 16, color: Colors.white),
                label: const Text('Return', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance logs coming soon')));
                },
                icon: const Icon(Icons.build, size: 16, color: Colors.white),
                label: const Text('Maint.', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlertsBanner() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening detailed alerts view...')));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1 Critical Alert',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Device DE-042 missed heartbeat (30m+ offline)',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSessionsCarousel() {
    return SizedBox(
      height: 120,
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
            isExpanded: false,
          ),
          _buildLiveGlowingCard(
            yard: 'South Yard',
            line: 'Line 2',
            ldDevice: 'LD-014',
            deDevice: 'DE-008',
            distance: '24.5m',
            isClosing: false,
            isExpanded: false,
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
    required bool isExpanded,
  }) {
    return Container(
      width: isExpanded ? double.infinity : 240,
      margin: EdgeInsets.only(right: isExpanded ? 0 : 12.0, bottom: isExpanded ? 12.0 : 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClosing ? Colors.redAccent.withValues(alpha: 0.8) : Colors.blueAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isClosing ? Colors.redAccent.withValues(alpha: 0.3) : Colors.blueAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -15,
            right: -15,
            child: Icon(
              Icons.radar,
              size: isExpanded ? 80 : 60,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$yard • $line',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('LIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isExpanded ? 24 : 16), // Spacer equivalent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pairing', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(
                          '$ldDevice ↔ $deDevice',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isClosing ? 'HAZARD - TOO CLOSE' : 'Approaching',
                          style: TextStyle(
                            color: isClosing ? Colors.redAccent : Colors.blueAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
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

  Widget _buildHealthSummaryGrid({
    required String title1, 
    required String title2, 
    required String title3, 
    required String title4
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHealthCard(title1, '42', Icons.memory, Colors.blue),
          _buildHealthCard(title2, '2', Icons.wifi_off, Colors.red),
          _buildHealthCard(title3, '18', Icons.history, Colors.purple),
          _buildHealthCard(title4, '98%', Icons.check_circle_outline, Colors.green),
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                    color: color.withValues(alpha: 0.1),
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
