import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DataManagementSection extends StatefulWidget {
  final VoidCallback onAccountDeleted;

  const DataManagementSection({
    Key? key,
    required this.onAccountDeleted,
  }) : super(key: key);

  @override
  State<DataManagementSection> createState() => _DataManagementSectionState();
}

class _DataManagementSectionState extends State<DataManagementSection> {
  bool _isLoading = false;

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true;

    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _backupInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock inventory data for backup
      final inventoryData = {
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0',
        'inventory': [
          {
            'id': 1,
            'name': 'Wireless Headphones',
            'category': 'Electronics',
            'price': 89.99,
            'quantity': 25,
            'sku': 'WH001',
            'description':
                'High-quality wireless headphones with noise cancellation',
          },
          {
            'id': 2,
            'name': 'Coffee Mug',
            'category': 'Home & Kitchen',
            'price': 12.50,
            'quantity': 50,
            'sku': 'CM002',
            'description': 'Ceramic coffee mug with ergonomic handle',
          },
          {
            'id': 3,
            'name': 'Notebook Set',
            'category': 'Stationery',
            'price': 15.99,
            'quantity': 30,
            'sku': 'NB003',
            'description': 'Set of 3 lined notebooks for writing',
          },
        ],
        'categories': ['Electronics', 'Home & Kitchen', 'Stationery'],
        'total_items': 3,
        'total_quantity': 105,
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(inventoryData);
      final fileName =
          'inventory_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await _downloadFile(jsonString, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Inventory backup completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: Please try again'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  Future<void> _restoreInventoryData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });

        List<int>? fileBytes;
        if (kIsWeb) {
          fileBytes = result.files.first.bytes;
        } else {
          final file = File(result.files.first.path!);
          fileBytes = await file.readAsBytes();
        }

        if (fileBytes != null) {
          final jsonString = utf8.decode(fileBytes);
          final data = jsonDecode(jsonString);

          // Validate backup data structure
          if (data['inventory'] != null && data['version'] != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Inventory restored successfully')),
              );
            }
          } else {
            throw Exception('Invalid backup file format');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: Invalid backup file'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock inventory data for export
      final csvData = [
        ['ID', 'Name', 'Category', 'Price', 'Quantity', 'SKU', 'Description'],
        [
          '1',
          'Wireless Headphones',
          'Electronics',
          '89.99',
          '25',
          'WH001',
          'High-quality wireless headphones with noise cancellation'
        ],
        [
          '2',
          'Coffee Mug',
          'Home & Kitchen',
          '12.50',
          '50',
          'CM002',
          'Ceramic coffee mug with ergonomic handle'
        ],
        [
          '3',
          'Notebook Set',
          'Stationery',
          '15.99',
          '30',
          'NB003',
          'Set of 3 lined notebooks for writing'
        ],
      ];

      final csvString = csvData.map((row) => row.join(',')).join('\n');
      final fileName =
          'inventory_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      await _downloadFile(csvString, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: Please try again'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAccountDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Type "DELETE" to confirm account deletion:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAccountDeleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'storage',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'backup',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Backup Inventory'),
            subtitle: const Text('Create a backup of your inventory data'),
            trailing: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
            onTap: _isLoading ? null : _backupInventoryData,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'restore',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Restore Inventory'),
            subtitle: const Text('Restore inventory from backup file'),
            trailing: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
            onTap: _isLoading ? null : _restoreInventoryData,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'file_download',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Export Data'),
            subtitle: const Text('Export inventory data as CSV'),
            trailing: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : CustomIconWidget(
                    iconName: 'chevron_right',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
            onTap: _isLoading ? null : _exportInventoryData,
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'delete_forever',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Permanently delete your account and data'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}
