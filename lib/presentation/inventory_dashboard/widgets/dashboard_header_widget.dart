import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final String businessName;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const DashboardHeaderWidget({
    Key? key,
    required this.businessName,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      businessName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Stack(
                        children: [
                          CustomIconWidget(
                            iconName: 'notifications',
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 6.w,
                          ),
                          notificationCount > 0
                              ? Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 4.w,
                                      minHeight: 4.w,
                                    ),
                                    child: Text(
                                      notificationCount > 99
                                          ? '99+'
                                          : notificationCount.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 8.sp,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'search',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Search inventory...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'tune',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
