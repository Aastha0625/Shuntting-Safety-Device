import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class DeviceInventoryScreen extends StatefulWidget {
  const DeviceInventoryScreen({super.key});

  @override
  State<DeviceInventoryScreen> createState() => _DeviceInventoryScreenState();
}

class _DeviceInventoryScreenState extends State<DeviceInventoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allDevices = [];
  String _selectedTypeFilter = 'All Devices';
  final List<String> _typeFilters = ['All Devices', 'Loco Unit', 'Dead-End', 'Portable', 'Coupling'];

  @override
  void initState() {
    super.initState();
    _fetchMockDevices();
  }

  Future<void> _fetchMockDevices() async {
    setState(() => _isLoading = true);
    // Simulate network delay for API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    _allDevices = [
      {
        'uuid': '8f3e2-1a4', 'code': 'DE-042', 'type': 'Dead-End', 'yard': 'North Yard',
        'line': 'Line 4', 'serial': 'SN-998822', 'isOnline': false, 'simOperator': 'Airtel',
        'simValid': '2027-01-15', 'status': 'Needs Repair', 'holder': 'N/A', 'lastHeartbeat': '30m ago'
      },
      {
        'uuid': '1b4a9-8e2', 'code': 'LD-001', 'type': 'Loco Unit', 'yard': 'North Yard',
        'line': 'N/A', 'serial': 'SN-554411', 'isOnline': true, 'simOperator': 'Jio',
        'simValid': '2026-12-01', 'status': 'Active', 'holder': 'Loco Pilot Raj', 'lastHeartbeat': '2m ago'
      },
      {
        'uuid': '7c2d1-9f5', 'code': 'PD-011', 'type': 'Portable', 'yard': 'South Yard',
        'line': 'N/A', 'serial': 'SN-223344', 'isOnline': true, 'simOperator': 'Vodafone',
        'simValid': '2026-10-20', 'status': 'Active', 'holder': 'Shunter Amit', 'lastHeartbeat': '1m ago'
      },
      {
        'uuid': '2a9b3-4c6', 'code': 'DE-012', 'type': 'Dead-End', 'yard': 'South Yard',
        'line': 'Line 2', 'serial': 'SN-112233', 'isOnline': true, 'simOperator': 'Airtel',
        'simValid': '2027-03-10', 'status': 'Active', 'holder': 'N/A', 'lastHeartbeat': '12m ago'
      },
      {
        'uuid': '9m4x2-1p9', 'code': 'LD-014', 'type': 'Loco Unit', 'yard': 'South Yard',
        'line': 'N/A', 'serial': 'SN-887766', 'isOnline': true, 'simOperator': 'Jio',
        'simValid': '2027-06-25', 'status': 'Active', 'holder': 'Loco Pilot Dev', 'lastHeartbeat': '5m ago'
      },
    ];
    
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredDevices {
    if (_selectedTypeFilter == 'All Devices') return _allDevices;
    return _allDevices.where((d) => d['type'] == _selectedTypeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Device Inventory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildDeviceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegistrationForm,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: _typeFilters.map((filter) {
            final isSelected = filter == _selectedTypeFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTypeFilter = filter);
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.subtitleColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppTheme.backgroundColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    final devices = _filteredDevices;
    if (devices.isEmpty) {
      return const Center(
        child: Text('No devices found.', style: TextStyle(color: AppTheme.subtitleColor)),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isOnline = device['isOnline'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          device['type'] == 'Dead-End' ? Icons.vertical_align_bottom : Icons.memory,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          device['code'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isOnline ? Colors.green.shade200 : Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(color: isOnline ? Colors.green.shade700 : Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Type', device['type'])),
                    Expanded(child: _buildInfoItem('Yard', device['yard'])),
                    Expanded(child: _buildInfoItem('Line', device['line'])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('SIM Valid', device['simValid'])),
                    Expanded(child: _buildInfoItem('Holder', device['holder'])),
                    Expanded(child: _buildInfoItem('Heartbeat', device['lastHeartbeat'])),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
        const SizedBox(height: 2),
        Text(
          value, 
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showRegistrationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Register New Device', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTextField('Device Code', 'e.g. LD-045'),
                  const SizedBox(height: 16),
                  _buildDropdownField('Device Type', ['Loco Unit', 'Dead-End', 'Portable', 'Coupling']),
                  const SizedBox(height: 16),
                  _buildTextField('Serial Number', 'Enter HW serial number'),
                  const SizedBox(height: 16),
                  _buildDropdownField('Yard', ['North Yard', 'South Yard', 'East Yard']),
                  const SizedBox(height: 16),
                  _buildTextField('SIM Operator', 'e.g. Airtel, Jio'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Device Registered successfully!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SAVE & REGISTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.first,
              items: options.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
