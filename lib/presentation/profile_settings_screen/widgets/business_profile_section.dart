import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BusinessProfileSection extends StatefulWidget {
  final Map<String, dynamic> businessData;
  final Function(Map<String, dynamic>) onBusinessDataChanged;

  const BusinessProfileSection({
    Key? key,
    required this.businessData,
    required this.onBusinessDataChanged,
  }) : super(key: key);

  @override
  State<BusinessProfileSection> createState() => _BusinessProfileSectionState();
}

class _BusinessProfileSectionState extends State<BusinessProfileSection> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _shopNameController.text = widget.businessData['shopName'] ?? '';
    _addressController.text = widget.businessData['address'] ?? '';
    _phoneController.text = widget.businessData['phone'] ?? '';
    _emailController.text = widget.businessData['email'] ?? '';
  }

  void _updateBusinessData() {
    final updatedData = {
      ...widget.businessData,
      'shopName': _shopNameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
    };
    widget.onBusinessDataChanged(updatedData);
  }

  void _showBusinessHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => BusinessHoursDialog(
        businessHours: widget.businessData['businessHours'] ?? {},
        onHoursChanged: (hours) {
          final updatedData = {
            ...widget.businessData,
            'businessHours': hours,
          };
          widget.onBusinessDataChanged(updatedData);
        },
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
                iconName: 'business',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Business Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextFormField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              labelText: 'Shop Name',
              hintText: 'Enter your shop name',
            ),
            onChanged: (_) => _updateBusinessData(),
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your business address',
              suffixIcon: IconButton(
                onPressed: () {
                  // Location picker functionality would be implemented here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Location picker coming soon')),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'location_on',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            maxLines: 2,
            onChanged: (_) => _updateBusinessData(),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+1 (555) 123-4567',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _updateBusinessData(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'shop@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _updateBusinessData(),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'schedule',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            title: const Text('Business Hours'),
            subtitle: Text(
              _getBusinessHoursText(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showBusinessHoursDialog,
          ),
        ],
      ),
    );
  }

  String _getBusinessHoursText() {
    final hours = widget.businessData['businessHours'] as Map<String, dynamic>?;
    if (hours == null || hours.isEmpty) {
      return 'Tap to set business hours';
    }
    return 'Mon-Fri: 9:00 AM - 6:00 PM';
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class BusinessHoursDialog extends StatefulWidget {
  final Map<String, dynamic> businessHours;
  final Function(Map<String, dynamic>) onHoursChanged;

  const BusinessHoursDialog({
    Key? key,
    required this.businessHours,
    required this.onHoursChanged,
  }) : super(key: key);

  @override
  State<BusinessHoursDialog> createState() => _BusinessHoursDialogState();
}

class _BusinessHoursDialogState extends State<BusinessHoursDialog> {
  late Map<String, dynamic> _hours;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _hours = Map.from(widget.businessHours);

    // Initialize default hours if empty
    for (String day in _days) {
      if (!_hours.containsKey(day)) {
        _hours[day] = {
          'isOpen': day != 'Sunday',
          'openTime': '09:00',
          'closeTime': '18:00',
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Business Hours'),
      content: SizedBox(
        width: 80.w,
        height: 60.h,
        child: SingleChildScrollView(
          child: Column(
            children: _days.map((day) => _buildDayRow(day)).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onHoursChanged(_hours);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDayRow(String day) {
    final dayData = _hours[day] as Map<String, dynamic>;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              day.substring(0, 3),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: dayData['isOpen'] ?? false,
            onChanged: (value) {
              setState(() {
                _hours[day] = {
                  ..._hours[day],
                  'isOpen': value,
                };
              });
            },
          ),
          if (dayData['isOpen'] ?? false) ...[
            SizedBox(width: 2.w),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(day, 'openTime'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dayData['openTime'] ?? '09:00',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: const Text('-'),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(day, 'closeTime'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dayData['closeTime'] ?? '18:00',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Closed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime(String day, String timeType) async {
    final currentTime = _hours[day][timeType] ?? '09:00';
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        _hours[day] = {
          ..._hours[day],
          timeType:
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        };
      });
    }
  }
}
