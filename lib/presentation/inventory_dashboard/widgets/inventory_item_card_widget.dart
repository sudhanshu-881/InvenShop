import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InventoryItemCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final VoidCallback? onEditStock;
  final VoidCallback? onAddToMarketplace;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDuplicate;
  final VoidCallback? onArchive;
  final VoidCallback? onShare;

  const InventoryItemCardWidget({
    Key? key,
    required this.item,
    this.onTap,
    this.onEditStock,
    this.onAddToMarketplace,
    this.onViewDetails,
    this.onDuplicate,
    this.onArchive,
    this.onShare,
  }) : super(key: key);

  Color _getStockStatusColor(int stock) {
    if (stock <= 5) return AppTheme.errorLight;
    if (stock <= 20) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  String _getStockStatus(int stock) {
    if (stock <= 5) return 'Low';
    if (stock <= 20) return 'Medium';
    return 'Good';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stock = item['stock'] as int;
    final statusColor = _getStockStatusColor(stock);
    final statusText = _getStockStatus(stock);

    return Slidable(
      key: ValueKey(item['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEditStock?.call(),
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onAddToMarketplace?.call(),
            backgroundColor: AppTheme.secondaryLight,
            foregroundColor: Colors.white,
            icon: Icons.store,
            label: 'Market',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onViewDetails?.call(),
            backgroundColor: AppTheme.successLight,
            foregroundColor: Colors.white,
            icon: Icons.visibility,
            label: 'View',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                AppTheme.getElevationShadow(elevation: 1, isLight: !isDark),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: item['image'] as String,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                  semanticLabel: item['semanticLabel'] as String,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      item['category'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$stock units',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['price'] as String,
                    style: AppTheme.priceTextStyle(
                      isLight: !isDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onEditStock,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CustomIconWidget(
                            iconName: 'edit',
                            color: AppTheme.primaryLight,
                            size: 4.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: onAddToMarketplace,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.secondaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CustomIconWidget(
                            iconName: 'store',
                            color: AppTheme.secondaryLight,
                            size: 4.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
