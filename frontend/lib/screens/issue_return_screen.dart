import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class IssueReturnScreen extends StatefulWidget {
  const IssueReturnScreen({Key? key}) : super(key: key);

  @override
  State<IssueReturnScreen> createState() => _IssueReturnScreenState();
}

class _IssueReturnScreenState extends State<IssueReturnScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableDevices = [];
  List<Map<String, dynamic>> _issuedDevices = [];

  @override
  void initState() {
    super.initState();
    _fetchMockData();
  }

  Future<void> _fetchMockData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    _availableDevices = [
      {'code': 'LD-005', 'type': 'Loco Unit', 'battery': '92%', 'condition': 'Good', 'sim': 'Active'},
      {'code': 'PD-022', 'type': 'Portable', 'battery': '100%', 'condition': 'Good', 'sim': 'Active'},
      {'code': 'CD-014', 'type': 'Coupling', 'battery': '88%', 'condition': 'Good', 'sim': 'Active'},
    ];

    _issuedDevices = [
      {
        'code': 'LD-001', 'type': 'Loco Unit', 'employee': 'Rajesh Kumar', 'id': 'EMP-1102',
        'designation': 'Loco Pilot', 'issueTime': '08:15 AM', 'battery': '45%'
      },
      {
        'code': 'PD-011', 'type': 'Portable', 'employee': 'Amit Singh', 'id': 'EMP-2294',
        'designation': 'Shunter', 'issueTime': '09:30 AM', 'battery': '60%'
      },
    ];

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Issue & Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Tab(icon: Icon(Icons.outbox), text: 'AVAILABLE POOL'),
              Tab(icon: Icon(Icons.assignment_ind), text: 'CURRENTLY ISSUED'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAvailableTab(),
                  _buildIssuedTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildAvailableTab() {
    if (_availableDevices.isEmpty) {
      return const Center(child: Text('No devices available in the pool.', style: TextStyle(color: AppTheme.subtitleColor)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _availableDevices.length,
      itemBuilder: (context, index) {
        final device = _availableDevices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.memory, color: Colors.blueAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device['code'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      const SizedBox(height: 4),
                      Text('${device['type']} • Battery: ${device['battery']}', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showIssueForm(device['code'], device['type']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('ISSUE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIssuedTab() {
    if (_issuedDevices.isEmpty) {
      return const Center(child: Text('No devices currently issued.', style: TextStyle(color: AppTheme.subtitleColor)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _issuedDevices.length,
      itemBuilder: (context, index) {
        final device = _issuedDevices[index];
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
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(device['employee'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      ],
                    ),
                    Text(device['issueTime'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoCol('Device', device['code'])),
                    Expanded(child: _buildInfoCol('ID', device['id'])),
                    Expanded(child: _buildInfoCol('Role', device['designation'])),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () => _showReturnForm(device['code'], device['employee']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('RETURN DEVICE', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
      ],
    );
  }

  void _showIssueForm(String code, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Issue $code', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildTextField('Employee Name', 'e.g. Rahul Kumar'),
                    const SizedBox(height: 16),
                    _buildTextField('Employee ID', 'e.g. EMP-9821'),
                    const SizedBox(height: 16),
                    _buildDropdownField('Designation', ['Loco Pilot', 'Shunter', 'Pointsman', 'Other']),
                    const SizedBox(height: 16),
                    _buildDropdownField('Device Condition at Issue', ['Good', 'Damaged', 'Requires Charge']),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$code Issued Successfully!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('CONFIRM ISSUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReturnForm(String code, String employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Return $code', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Text('Currently held by $employee', style: const TextStyle(color: AppTheme.subtitleColor)),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildDropdownField('Device Condition at Return', ['Good', 'Damaged', 'Faulty']),
                    const SizedBox(height: 16),
                    _buildDropdownField('Fault Reported?', ['No', 'Yes - Software', 'Yes - Hardware']),
                    const SizedBox(height: 16),
                    _buildTextField('Remarks (Optional)', 'Any additional notes...'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$code Returned Successfully!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('CONFIRM RETURN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
