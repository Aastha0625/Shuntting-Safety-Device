import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTime = 'Daily';
  String _selectedReportType = 'Daily Shunting';

  final List<String> _timeTabs = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _reportTypes = [
    'Daily Shunting',
    'Employee Device Usage',
    'Loco Device',
    'Dead-End Device',
    'Device Health',
    'Device Failure',
    'Device Inventory',
    'SIM & Maintenance',
    'Coupling'
  ];

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
        title: const Text(
          'Reports & Audits',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeTabs(),
              const SizedBox(height: 16),
              _buildReportTypeSelector(),
              const SizedBox(height: 24),
              _buildFilterPanel(),
              const SizedBox(height: 24),
              _buildActionBar(),
              const SizedBox(height: 32),
              _buildResultsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: _timeTabs.map((tab) {
          final isSelected = tab == _selectedTime;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTime = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.subtitleColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT REPORT TYPE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppTheme.subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedReportType,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.subtitleColor),
              items: _reportTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedReportType = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _showFilter(String filter) {
    if (filter == 'Yard') return true; // Always visible
    
    switch (_selectedReportType) {
      case 'Daily Shunting':
        return ['Device Code', 'Line', 'Employee', 'Session Status'].contains(filter);
      case 'Employee Device Usage':
        return ['Employee', 'Device Type', 'Device Code'].contains(filter);
      case 'Loco Device':
        return ['Device Code', 'Line', 'Employee', 'Session Status'].contains(filter);
      case 'Dead-End Device':
        return ['Line', 'Device Code', 'Device Health'].contains(filter);
      case 'Device Health':
        return ['Device Type', 'Device Code', 'Device Health'].contains(filter);
      case 'Device Failure':
        return ['Device Type', 'Device Code', 'Line'].contains(filter);
      case 'Device Inventory':
        return ['Device Type', 'Device Code', 'Device Health', 'Maintenance Status'].contains(filter);
      case 'SIM & Maintenance':
        return ['Device Type', 'Device Code', 'SIM Status', 'Maintenance Status'].contains(filter);
      case 'Coupling':
        return ['Device Type', 'Device Code', 'Line', 'Session Status'].contains(filter);
      default:
        return true; 
    }
  }

  Map<String, String> _getDateRange() {
    final now = DateTime.now();
    DateTime fromDate;
    
    switch (_selectedTime) {
      case 'Daily':
        fromDate = now;
        break;
      case 'Weekly':
        fromDate = now.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        fromDate = now.subtract(const Duration(days: 30));
        break;
      case 'Custom':
      default:
        fromDate = DateTime(2026, 7, 1);
    }
    
    String format(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      'from': format(fromDate),
      'to': format(now),
    };
  }

  Widget _buildFilterPanel() {
    List<Widget> activeFilters = [];
    
    if (_showFilter('Yard')) activeFilters.add(_buildFilterDropdown('Yard', 'All Yards'));
    if (_showFilter('Employee')) activeFilters.add(_buildFilterDropdown('Employee', 'Search...'));
    if (_showFilter('Device Type')) activeFilters.add(_buildFilterDropdown('Device Type', 'Loco Unit'));
    if (_showFilter('Device Code')) activeFilters.add(_buildFilterDropdown('Device Code', 'Select...'));
    if (_showFilter('Line')) activeFilters.add(_buildFilterDropdown('Line', 'All Lines'));
    if (_showFilter('Session Status')) activeFilters.add(_buildFilterDropdown('Session Status', 'Completed'));
    if (_showFilter('Device Health')) activeFilters.add(_buildFilterDropdown('Device Health', 'Any Status'));
    if (_showFilter('SIM Status')) activeFilters.add(_buildFilterDropdown('SIM Status', 'Active'));
    if (_showFilter('Maintenance Status')) activeFilters.add(_buildFilterDropdown('Maintenance Status', 'All Statuses'));

    List<Widget> dynamicRows = [];
    for (int i = 0; i < activeFilters.length; i += 2) {
      if (i + 1 < activeFilters.length) {
        dynamicRows.add(
          Row(
            children: [
              Expanded(child: activeFilters[i]),
              const SizedBox(width: 16),
              Expanded(child: activeFilters[i + 1]),
            ],
          ),
        );
      } else {
        dynamicRows.add(
          Row(
            children: [
              Expanded(child: activeFilters[i]),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()), // Empty spacer for alignment
            ],
          ),
        );
      }
      dynamicRows.add(const SizedBox(height: 16));
    }

    final dates = _getDateRange();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, size: 20, color: AppTheme.subtitleColor),
              SizedBox(width: 8),
              Text(
                'DATE RANGE & FILTERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.subtitleColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilterInput('From Date', dates['from']!)),
              const SizedBox(width: 16),
              Expanded(child: _buildFilterInput('To Date', dates['to']!)),
            ],
          ),
          const SizedBox(height: 16),
          ...dynamicRows,
        ],
      ),
    );
  }

  Widget _buildFilterInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor)),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.subtitleColor),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadReport(String format) async {
    try {
      final dates = _getDateRange();
      final filters = {
        'Date Range': '${dates['from']} to ${dates['to']}',
        'Yard': 'All Yards'
      };
      
      final queryParams = {
        'reportType': _selectedReportType,
        'filters': jsonEncode(filters),
      };
      
      // Use 10.0.2.2 for Android emulator, or localhost for Windows/Web
      final uri = Uri.http('localhost:5000', '/api/reports/generate/$format', queryParams);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $format download. Make sure backend is running.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading $format: $e')),
        );
      }
    }
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _downloadReport('excel'),
            icon: const Icon(Icons.table_chart, color: Colors.greenAccent, size: 18),
            label: const Text('Excel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _downloadReport('pdf'),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 18),
            label: const Text('PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print, color: AppTheme.primaryColor, size: 18),
            label: const Text('Print', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(Icons.insert_chart_outlined, size: 64, color: AppTheme.subtitleColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No reports generated yet.',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your filters above and download the Excel or PDF.',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String date,
    required String id,
    required String status,
    required Color statusColor,
    required String yard,
    required String employee,
    required String devices,
    required String duration,
    required String minDist,
    required String finalDist,
    required int alerts,
    required int fails,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date | $id',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent Line
                Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      // Grid Info
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem('YARD / LINE', yard)),
                          Expanded(child: _buildInfoItem('EMPLOYEE', employee)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem('DEVICES', devices)),
                          Expanded(child: _buildInfoItem('DURATION', duration)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Distances
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppTheme.borderColor, style: BorderStyle.none)), // Actually we'll use a Divider below
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDistanceItem('MIN DIST', minDist),
                            Container(width: 1, height: 32, color: AppTheme.borderColor),
                            _buildDistanceItem('FINAL DIST', finalDist),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.borderColor),
                      // Footer Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, size: 16, color: alerts > 0 ? Colors.red : AppTheme.subtitleColor),
                              const SizedBox(width: 4),
                              Text('$alerts Alerts', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                              const SizedBox(width: 16),
                              Icon(Icons.signal_wifi_off, size: 16, color: fails > 0 ? Colors.red : AppTheme.subtitleColor),
                              const SizedBox(width: 4),
                              Text('$fails Fails', style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
                            ],
                          ),
                          Row(
                            children: const [
                              Text('Details', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                              Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryColor),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.subtitleColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDistanceItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.subtitleColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
