import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class YardSetupScreen extends StatefulWidget {
  const YardSetupScreen({super.key});

  @override
  State<YardSetupScreen> createState() => _YardSetupScreenState();
}

class _YardSetupScreenState extends State<YardSetupScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _yards = [];

  @override
  void initState() {
    super.initState();
    _fetchMockYards();
  }

  Future<void> _fetchMockYards() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate API delay
    
    _yards = [
      {
        'id': 'YRD-001',
        'name': 'North Yard',
        'station': 'Central Hub',
        'type': 'Mixed',
        'lines': [
          {'id': 'LN-101', 'name': 'Pit Line 1', 'type': 'Pit Line', 'deName': 'Pit Line 1 Dead End', 'assignedDE': 'DE-042', 'status': 'Active'},
          {'id': 'LN-102', 'name': 'Stabling Line 4', 'type': 'Stabling Line', 'deName': 'Stabling 4 Dead End', 'assignedDE': 'DE-019', 'status': 'Active'},
          {'id': 'LN-103', 'name': 'Maintenance Line A', 'type': 'Maintenance', 'deName': 'Maint A Dead End', 'assignedDE': 'None', 'status': 'Inactive'},
        ]
      },
      {
        'id': 'YRD-002',
        'name': 'South Yard',
        'station': 'Central Hub',
        'type': 'Freight',
        'lines': [
          {'id': 'LN-201', 'name': 'Siding 1', 'type': 'Siding', 'deName': 'Siding 1 Dead End', 'assignedDE': 'DE-012', 'status': 'Active'},
          {'id': 'LN-202', 'name': 'Siding 2', 'type': 'Siding', 'deName': 'Siding 2 Dead End', 'assignedDE': 'DE-088', 'status': 'Active'},
        ]
      },
    ];
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Yard & Line Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildYardList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMenu,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildYardList() {
    if (_yards.isEmpty) {
      return const Center(child: Text('No yards configured yet.', style: TextStyle(color: AppTheme.subtitleColor)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _yards.length,
      itemBuilder: (context, index) {
        final yard = _yards[index];
        final List lines = yard['lines'] ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            title: Text(
              yard['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
            ),
            subtitle: Text('${yard['station']} • ${yard['type']} • ${lines.length} Lines', style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 13)),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.factory, color: AppTheme.primaryColor),
            ),
            children: [
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CONFIGURED LINES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor, letterSpacing: 1.0)),
                        TextButton.icon(
                          onPressed: () => _showLineForm(),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Line'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...lines.map((line) => _buildLineItem(line)),
                    if (lines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No lines configured in this yard.', style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.subtitleColor)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineItem(Map<String, dynamic> line) {
    final bool isActive = line['status'] == 'Active';
    final bool hasDevice = line['assignedDE'] != 'None';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.route, size: 18, color: isActive ? AppTheme.primaryColor : Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    line['name'],
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isActive ? AppTheme.primaryColor : Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isActive ? Colors.green.shade200 : Colors.grey.shade300),
                ),
                child: Text(
                  line['status'],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.grey.shade600),
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
                  children: [
                    const Text('Line Type', style: TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
                    Text(line['type'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dead-End Target', style: TextStyle(fontSize: 11, color: AppTheme.subtitleColor)),
                    Text(line['deName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.vertical_align_bottom, size: 16, color: AppTheme.subtitleColor),
                  const SizedBox(width: 4),
                  const Text('Assigned Device: ', style: TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                  Text(
                    line['assignedDE'],
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: hasDevice ? Colors.blueAccent : Colors.redAccent
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, size: 20, color: AppTheme.subtitleColor),
                onPressed: () => _showAssignForm(line['name']),
                tooltip: 'Edit Assignment',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create New...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.factory, color: AppTheme.primaryColor)),
              title: const Text('Yard'),
              subtitle: const Text('Add a new train yard to the station'),
              onTap: () {
                Navigator.pop(context);
                _showYardForm();
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.route, color: AppTheme.primaryColor)),
              title: const Text('Line'),
              subtitle: const Text('Add a new line to an existing yard'),
              onTap: () {
                Navigator.pop(context);
                _showLineForm();
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showYardForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Create Yard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildTextField('Yard Name', 'e.g. North Yard'),
                  const SizedBox(height: 16),
                  _buildTextField('Yard Code', 'e.g. NY-01'),
                  const SizedBox(height: 16),
                  _buildTextField('Station', 'e.g. Central Hub'),
                  const SizedBox(height: 16),
                  _buildDropdownField('Yard Type', ['Mixed', 'Freight', 'Coaching', 'Depot']),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Yard Created!')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SAVE YARD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showLineForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Line', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _buildDropdownField('Select Yard', ['North Yard', 'South Yard']),
                    const SizedBox(height: 16),
                    _buildTextField('Line Name', 'e.g. Pit Line 5'),
                    const SizedBox(height: 16),
                    _buildDropdownField('Line Type', ['Pit Line', 'Stabling Line', 'Siding', 'Maintenance']),
                    const SizedBox(height: 16),
                    _buildDropdownField('Assign Dead-End Device (Optional)', ['None', 'DE-042', 'DE-019']),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Line Created!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SAVE LINE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showAssignForm(String lineName) {
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
                  Text('Assign Device to $lineName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDropdownField('Select Dead-End Device', ['None', 'DE-042', 'DE-019', 'DE-088']),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment Updated!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAVE ASSIGNMENT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
