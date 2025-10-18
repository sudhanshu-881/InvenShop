import 'package:flutter/material.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/marketplace_browse_screen/marketplace_browse_screen.dart';
import '../presentation/inventory_dashboard/inventory_dashboard.dart';
import '../presentation/business_registration_screen/business_registration_screen.dart';
import '../presentation/analytics_dashboard_screen/analytics_dashboard_screen.dart';
import '../presentation/add_edit_product_screen/add_edit_product_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String profileSettings = '/profile-settings-screen';
  static const String marketplaceBrowse = '/marketplace-browse-screen';
  static const String inventoryDashboard = '/inventory-dashboard';
  static const String businessRegistration = '/business-registration-screen';
  static const String analyticsDashboard = '/analytics-dashboard-screen';
  static const String addEditProduct = '/add-edit-product-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const InventoryDashboard(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    marketplaceBrowse: (context) => const MarketplaceBrowseScreen(),
    inventoryDashboard: (context) => const InventoryDashboard(),
    businessRegistration: (context) => const BusinessRegistrationScreen(),
    analyticsDashboard: (context) => const AnalyticsDashboardScreen(),
    addEditProduct: (context) => const AddEditProductScreen(),
    // TODO: Add your other routes here
  };
}
