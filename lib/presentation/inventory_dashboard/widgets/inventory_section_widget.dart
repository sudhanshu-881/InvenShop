import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './inventory_item_card_widget.dart';

class InventorySectionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> items;
  final VoidCallback? onSeeAll;
  final Function(Map<String, dynamic>)? onItemTap;
  final Function(Map<String, dynamic>)? onEditStock;
  final Function(Map<String, dynamic>)? onAddToMarketplace;
  final Function(Map<String, dynamic>)? onViewDetails;
  final Function(Map<String, dynamic>)? onDuplicate;
  final Function(Map<String, dynamic>)? onArchive;
  final Function(Map<String, dynamic>)? onShare;

  const InventorySectionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
    this.onEditStock,
    this.onAddToMarketplace,
    this.onViewDetails,
    this.onDuplicate,
    this.onArchive,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              onSeeAll != null
                  ? GestureDetector(
                      onTap: onSeeAll,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See All',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(width: 1.w),
                            CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: Theme.of(context).colorScheme.primary,
                              size: 4.w,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        items.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InventoryItemCardWidget(
                    item: item,
                    onTap: () => onItemTap?.call(item),
                    onEditStock: () => onEditStock?.call(item),
                    onAddToMarketplace: () => onAddToMarketplace?.call(item),
                    onViewDetails: () => onViewDetails?.call(item),
                    onDuplicate: () => onDuplicate?.call(item),
                    onArchive: () => onArchive?.call(item),
                    onShare: () => onShare?.call(item),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'inventory_2',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No items found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add your first product to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
