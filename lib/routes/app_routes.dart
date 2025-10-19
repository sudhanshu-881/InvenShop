import 'package:flutter/material.dart';
import '../presentation/auth_screen/auth_screen.dart';
import '../presentation/auth_screen/simplified_auth_screen.dart';
import '../presentation/billing_screen/billing_screen.dart';
import '../presentation/billing_screen/simplified_billing_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/marketplace_browse_screen/marketplace_browse_screen.dart';
import '../presentation/inventory_dashboard/inventory_dashboard.dart';
import '../presentation/inventory_dashboard/simplified_dashboard.dart';
import '../presentation/business_registration_screen/business_registration_screen.dart';
import '../presentation/analytics_dashboard_screen/analytics_dashboard_screen.dart';
import '../presentation/add_edit_product_screen/add_edit_product_screen.dart';
import '../presentation/customer_management_screen/simplified_customer_screen.dart';
import '../presentation/product_management/simplified_product_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String auth = '/auth';
  static const String businessRegistration = '/business-registration-screen';
  static const String inventoryDashboard = '/inventory-dashboard';
  static const String billing = '/billing-screen';
  static const String addEditProduct = '/add-edit-product-screen';
  static const String marketplaceBrowse = '/marketplace-browse-screen';
  static const String analyticsDashboard = '/analytics-dashboard-screen';
  static const String profileSettings = '/profile-settings-screen';
  
  // Simplified routes
  static const String simplifiedAuth = '/simplified-auth';
  static const String simplifiedDashboard = '/simplified-dashboard';
  static const String simplifiedBilling = '/simplified-billing';
  static const String simplifiedCustomers = '/simplified-customers';
  static const String simplifiedProducts = '/simplified-products';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SimplifiedAuthScreen(),
    auth: (context) => const AuthScreen(),
    businessRegistration: (context) => const BusinessRegistrationScreen(),
    inventoryDashboard: (context) => const InventoryDashboard(),
    billing: (context) => const BillingScreen(),
    addEditProduct: (context) => const AddEditProductScreen(),
    marketplaceBrowse: (context) => const MarketplaceBrowseScreen(),
    analyticsDashboard: (context) => const AnalyticsDashboardScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    
    // Simplified routes
    simplifiedAuth: (context) => const SimplifiedAuthScreen(),
    simplifiedDashboard: (context) => const SimplifiedDashboard(),
    simplifiedBilling: (context) => const SimplifiedBillingScreen(),
    simplifiedCustomers: (context) => const SimplifiedCustomerScreen(),
    simplifiedProducts: (context) => const SimplifiedProductScreen(),
  };
}
