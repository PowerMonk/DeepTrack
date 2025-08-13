import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<Map<String, dynamic>> sqliteData = [];
  String databasePath = '';
  Map<String, dynamic> dataSummary = {};
  bool isLoading = true;
  String? exportMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      exportMessage = null;
    });

    try {
      final data = await DatabaseService.getAllDailyStats();
      final path = await ExportService.getDatabasePath();
      final summary = await ExportService.getDataSummary();

      if (mounted) {
        setState(() {
          sqliteData = data;
          databasePath = path;
          dataSummary = summary;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _exportData() async {
    try {
      setState(() {
        exportMessage = 'Exporting...';
      });

      final filePath = await ExportService.exportToCSV();

      setState(() {
        exportMessage = 'Exported and path copied to clipboard!';
      });

      // Show longer duration snackbar with clipboard confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data exported successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('File path copied to clipboard'),
                const SizedBox(height: 4),
                Text(
                  filePath,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            duration: const Duration(seconds: 8), // Extended duration
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }

      // Auto-clear message after 8 seconds
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() {
            exportMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        exportMessage = 'Export failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyPathToClipboard() {
    Clipboard.setData(ClipboardData(text: databasePath));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Database path copied to clipboard'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromARGB(255, 250, 250, 250);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Image.asset('assets/images/baticon.png', height: 32, width: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Database View',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCurrentDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Database Path Card
            _buildDatabasePathCard(),
            const SizedBox(height: 16),

            // Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // Export Message
            if (exportMessage != null) _buildExportMessage(),

            // Data Table
            _buildDataTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportData,
        backgroundColor: Colors.black,
        child: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }

  Widget _buildDatabasePathCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SQLite Database Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _copyPathToClipboard,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder, color: Colors.black54, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        databasePath,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Icon(Icons.copy, color: Colors.black54, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to copy path to clipboard',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            if (dataSummary.isNotEmpty) ...[
              _buildSummaryRow(
                'Total Entries',
                '${dataSummary['totalEntries']}',
              ),
              _buildSummaryRow('Date Range', dataSummary['dateRange']),
              _buildSummaryRow(
                'Total Work Hours',
                '${dataSummary['totalWorkHours'].toStringAsFixed(1)}h',
              ),
              _buildSummaryRow(
                'Total Study Hours',
                '${dataSummary['totalStudyHours'].toStringAsFixed(1)}h',
              ),
              _buildSummaryRow(
                'Total Exercise Hours',
                '${dataSummary['totalExerciseHours'].toStringAsFixed(1)}h',
              ),
              _buildSummaryRow(
                'Total Social Hours',
                '${dataSummary['totalSocialHours'].toStringAsFixed(1)}h',
              ),
              _buildSummaryRow(
                'Total Rest Hours',
                '${dataSummary['totalRestHours'].toStringAsFixed(1)}h',
              ),
            ] else ...[
              const Text(
                'Loading summary...',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildExportMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        color: exportMessage!.contains('failed')
            ? Colors.red[50]
            : Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                exportMessage!.contains('failed')
                    ? Icons.error
                    : Icons.check_circle,
                color: exportMessage!.contains('failed')
                    ? Colors.red
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exportMessage!,
                  style: TextStyle(
                    color: exportMessage!.contains('failed')
                        ? Colors.red[800]
                        : Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SQLite Data (${sqliteData.length} entries)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (sqliteData.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.storage,
                        size: 48,
                        color: Colors.black54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No data found in database',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start tracking activities to see data here',
                        style: TextStyle(fontSize: 14, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Work (h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Study (h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Exercise (h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Social (h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Rest (h)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: sqliteData.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row['date'] ?? '')),
                        DataCell(
                          Text(
                            '${(row['work_hours'] / 60.0).toStringAsFixed(1)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(row['study_hours'] / 60.0).toStringAsFixed(1)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(row['exercise_hours'] / 60.0).toStringAsFixed(1)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(row['social_hours'] / 60.0).toStringAsFixed(1)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(row['rest_hours'] / 60.0).toStringAsFixed(1)}',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
