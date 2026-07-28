import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({Key? key}) : super(key: key);

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  // Mock Live Data
  final List<Map<String, dynamic>> _liveSessions = [
    {
      'id': 'SES-8921',
      'ld': 'LD-005',
      'de': 'DE-042',
      'yard': 'North Yard',
      'line': 'Pit Line 1',
      'distance': '45.2 m',
      'startTime': '14:20',
      'status': 'Active',
      'alerts': 0,
    },
    {
      'id': 'SES-8922',
      'ld': 'LD-001',
      'de': 'DE-019',
      'yard': 'South Yard',
      'line': 'Main Shunt Line',
      'distance': '12.8 m',
      'startTime': '14:45',
      'status': 'Warning',
      'alerts': 1,
    }
  ];

  // Mock History Data
  final List<Map<String, dynamic>> _historySessions = [
    {
      'id': 'SES-8910',
      'ld': 'LD-005',
      'de': 'DE-088',
      'yard': 'North Yard',
      'line': 'Stabling Line 2',
      'finalDistance': '1.2 m',
      'startTime': '09:15',
      'endTime': '10:30',
      'status': 'Completed',
    },
    {
      'id': 'SES-8905',
      'ld': 'LD-002',
      'de': 'DE-042',
      'yard': 'North Yard',
      'line': 'Pit Line 1',
      'finalDistance': '0.5 m',
      'startTime': '08:00',
      'endTime': '08:45',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Live Operations & Sessions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2A42), Color(0xFF0F172A)],
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.satellite_alt), text: 'LIVE OPERATIONS'),
              Tab(icon: Icon(Icons.history), text: 'SESSION HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLiveTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTab() {
    if (_liveSessions.isEmpty) {
      return const Center(child: Text('No active shunting sessions.', style: TextStyle(color: AppTheme.subtitleColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _liveSessions.length,
      itemBuilder: (context, index) {
        final session = _liveSessions[index];
        final isWarning = session['status'] == 'Warning';

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isWarning ? Colors.orangeAccent : AppTheme.borderColor),
          ),
          elevation: isWarning ? 4 : 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
                               color: isWarning ? Colors.orange : Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            session['status'].toUpperCase(),
                            style: TextStyle(
                              color: isWarning ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(session['id'], style: const TextStyle(color: AppTheme.subtitleColor, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBlock('Distance', session['distance'], isWarning ? Colors.orange : AppTheme.primaryColor, 24),
                    ),
                    Expanded(
                      child: _buildMetricBlock('Start Time', session['startTime'], AppTheme.primaryColor, 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDeviceLink(session['ld'], Icons.train),
                    const Icon(Icons.sync_alt, color: AppTheme.subtitleColor),
                    _buildDeviceLink(session['de'], Icons.stop_circle_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.subtitleColor),
                    const SizedBox(width: 4),
                    Text('${session['yard']} • ${session['line']}', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _historySessions.length,
      itemBuilder: (context, index) {
        final session = _historySessions[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(session['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    Text('${session['startTime']} - ${session['endTime']}', style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDeviceBadge(session['ld']),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.borderColor),
                    ),
                    _buildDeviceBadge(session['de']),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Final Placement', style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
                        Text(session['finalDistance'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${session['yard']} • ${session['line']}', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricBlock(String label, String value, Color color, double valueSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: valueSize, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDeviceLink(String deviceId, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(deviceId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildDeviceBadge(String deviceId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(deviceId, style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
    );
  }
}
