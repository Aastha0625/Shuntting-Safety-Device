import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
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
            const SizedBox(height: 16),
            _buildSectionTitle('AT A GLANCE'),
            _buildAtAGlanceSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('YARD SUMMARY'),
            _buildYardSummaryCard(
              yardName: 'North Yard',
              subtitle: 'Central Operations Hub',
              isActive: true,
              totalLines: 12,
              deDevices: 10,
              deHealthy: 9,
              deOffline: 1,
              portables: 4,
              activeSessions: 2,
              alertCount: 1,
            ),
            const SizedBox(height: 16),
            _buildYardSummaryCard(
              yardName: 'South Yard',
              subtitle: 'Maintenance & Storage',
              isActive: false,
              totalLines: 0, // Not displayed in simple inactive view
              deDevices: 0,
              deHealthy: 0,
              deOffline: 0,
              portables: 0,
              activeSessions: 0,
              alertCount: 0,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('ACTIVE SESSIONS'),
            _buildActiveSessionCard(),
            _buildSimpleActiveSessionCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.subtitleColor,
        ),
      ),
    );
  }

  Widget _buildAtAGlanceSection() {
    return SizedBox(
      height: 105,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildStatCard('Total Yards', '3', Icons.factory_outlined),
          _buildStatCard('Reg. Devices', '42', Icons.memory_outlined),
          _buildStatCard('Dead-End', '38', Icons.vertical_align_bottom_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYardSummaryCard({
    required String yardName,
    required String subtitle,
    required bool isActive,
    required int totalLines,
    required int deDevices,
    required int deHealthy,
    required int deOffline,
    required int portables,
    required int activeSessions,
    required int alertCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Teal left border indicator
          Container(
            width: 4,
            height: isActive ? 220 : 100,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(yardName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.teal.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Safe State' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.teal[700] : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildGridStat('Total Lines', totalLines.toString())),
                        Expanded(child: _buildGridStat('DE Devices', deDevices.toString())),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildGridStat('DE Healthy', deHealthy.toString(), valueColor: Colors.teal)),
                        Expanded(child: _buildGridStat('DE Offline', deOffline.toString(), valueColor: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildGridStat('Portables', portables.toString())),
                        Expanded(child: _buildGridStat('Active Sessions', activeSessions.toString())),
                      ],
                    ),
                    if (alertCount > 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '$alertCount Open Alert requires attention',
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppTheme.primaryColor : Colors.white,
                        foregroundColor: isActive ? Colors.white : AppTheme.primaryColor,
                        side: isActive ? null : const BorderSide(color: AppTheme.borderColor),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('VIEW YARD', style: TextStyle(fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStat(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 13)),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor ?? AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 250,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('#S-1042', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                          const Text('LTT Yard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            const Text('Active', style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 18, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor)),
                          Text('ID: RS-10294', style: TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('LOCO ID', style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
                            Text('LOCO-01', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('LINE', style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
                            Text('Line 4', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('DE CODE', style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
                            Text('DE-05', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('DISTANCE', style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
                            Text('42m', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: AppTheme.subtitleColor),
                          SizedBox(width: 4),
                          Text('Started 08:30 AM', style: TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.history, size: 12, color: AppTheme.subtitleColor),
                          SizedBox(width: 4),
                          Text('Last data: 2 mins ago', style: TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.visibility_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('VIEW LIVE'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActiveSessionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('#S-1045', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                      Text('North Yard • Line 2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const Icon(Icons.open_in_new, color: AppTheme.primaryColor, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
