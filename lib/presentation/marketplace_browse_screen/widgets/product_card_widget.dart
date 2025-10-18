import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductCardWidget({
    Key? key,
    required this.product,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              AppTheme.getElevationShadow(elevation: 2, isLight: !isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomImageWidget(
                imageUrl: product['image'] as String? ?? '',
                width: double.infinity,
                height: 20.h,
                fit: BoxFit.cover,
                semanticLabel:
                    product['semanticLabel'] as String? ?? 'Product image',
              ),
            ),

            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] as String? ?? 'Unknown Product',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 1.h),

                  // Price
                  Text(
                    product['price'] as String? ?? '\$0.00',
                    style: AppTheme.priceTextStyle(
                      isLight: !isDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // Shopkeeper Info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product['shopkeeper'] as String? ?? 'Unknown Shop',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(width: 2.w),

                      // Distance
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            size: 12.sp,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            product['distance'] as String? ?? '0 km',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10.sp,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final rating = (product['rating'] as double?) ?? 0.0;
                        return CustomIconWidget(
                          iconName:
                              index < rating.floor() ? 'star' : 'star_border',
                          size: 12.sp,
                          color: Colors.amber,
                        );
                      }),
                      SizedBox(width: 2.w),
                      Text(
                        '(${product['rating']?.toStringAsFixed(1) ?? '0.0'})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10.sp,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
