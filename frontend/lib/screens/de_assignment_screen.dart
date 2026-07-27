import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class DEAssignmentScreen extends StatefulWidget {
  const DEAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<DEAssignmentScreen> createState() => _DEAssignmentScreenState();
}

class _DEAssignmentScreenState extends State<DEAssignmentScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    _assignments = [
      {'yard': 'North Yard', 'line': 'Pit Line 1', 'device': 'DE-042', 'status': 'Online', 'lastPing': '2m ago'},
      {'yard': 'North Yard', 'line': 'Stabling Line 2', 'device': 'DE-088', 'status': 'Offline', 'lastPing': '1h 30m ago'},
      {'yard': 'South Yard', 'line': 'Washing Line A', 'device': 'None', 'status': 'Unassigned', 'lastPing': '-'},
      {'yard': 'South Yard', 'line': 'Main Shunt Line', 'device': 'DE-019', 'status': 'Online', 'lastPing': 'Just now'},
    ];

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('DE Assignments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAssignmentList(),
    );
  }

  Widget _buildAssignmentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final item = _assignments[index];
        final bool isAssigned = item['device'] != 'None';
        final bool isOnline = item['status'] == 'Online';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['yard']} • ${item['line']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAssigned 
                            ? (isOnline ? Colors.green.shade100 : Colors.red.shade100)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAssigned 
                              ? (isOnline ? Colors.green.shade700 : Colors.red.shade700)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.router, color: AppTheme.subtitleColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isAssigned ? 'Assigned: ${item['device']}' : 'No device assigned',
                      style: TextStyle(
                        fontSize: 14,
                        color: isAssigned ? AppTheme.primaryColor : AppTheme.subtitleColor,
                        fontWeight: isAssigned ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (isAssigned) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text('Last Heartbeat: ${item['lastPing']}', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isAssigned)
                      TextButton.icon(
                        onPressed: () => _handleUnassign(item),
                        icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 18),
                        label: const Text('UNASSIGN', style: TextStyle(color: Colors.redAccent)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAssignForm(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(isAssigned ? Icons.swap_horiz : Icons.add_link, color: Colors.white, size: 18),
                      label: Text(isAssigned ? 'REPLACE' : 'ASSIGN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleUnassign(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment?'),
        content: Text('Are you sure you want to unassign ${item['device']} from ${item['line']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device Unassigned successfully!')));
            },
            child: const Text('UNASSIGN', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAssignForm(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assign Device to ${item['line']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Select Available Dead-End Device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: 'DE-101 (Available)',
                    items: ['DE-101 (Available)', 'DE-105 (Available)', 'DE-209 (Available)']
                        .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device Assigned to ${item['line']}!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CONFIRM ASSIGNMENT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
