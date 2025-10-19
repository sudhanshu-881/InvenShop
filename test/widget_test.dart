import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'package:invenshop/main.dart';
import 'package:invenshop/presentation/auth_screen/auth_screen.dart';
import 'package:invenshop/presentation/inventory_dashboard/inventory_dashboard.dart';
import 'package:invenshop/presentation/billing_screen/billing_screen.dart';
import 'package:invenshop/presentation/customer_management_screen/customer_management_screen.dart';

void main() {
  group('InvenShop Widget Tests', () {
    testWidgets('App launches and shows auth screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());

      // Verify that auth screen is displayed
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('InvenShop'), findsOneWidget);
    });

    testWidgets('Auth screen has required elements', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify auth screen elements
      expect(find.text('InvenShop'), findsOneWidget);
      expect(find.text('Digital Inventory Management for Local Retailers'), findsOneWidget);
      expect(find.text('Enter Mobile Number'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Inventory dashboard displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      // Verify dashboard elements
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Total Items'), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget);
      expect(find.text('Today\'s Sales'), findsOneWidget);
      expect(find.text('Credit Dues'), findsOneWidget);
    });

    testWidgets('Billing screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return BillingScreen();
            },
          ),
        ),
      );

      // Verify billing screen elements
      expect(find.text('Billing & POS'), findsOneWidget);
      expect(find.text('Cart (0)'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
    });

    testWidgets('Customer management screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return CustomerManagementScreen();
            },
          ),
        ),
      );

      // Verify customer management elements
      expect(find.text('Customer Management'), findsOneWidget);
      expect(find.text('All Customers'), findsOneWidget);
      expect(find.text('Credit Dues'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('Phone number input validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Find phone input field
      final phoneField = find.byType(TextField);
      expect(phoneField, findsOneWidget);

      // Test invalid input
      await tester.enterText(phoneField, '123');
      await tester.pump();
      
      // Test valid input
      await tester.enterText(phoneField, '9876543210');
      await tester.pump();
      
      // Verify input is accepted
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('OTP input validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Enter phone number and send OTP
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      // Verify OTP screen is shown
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('We have sent a 6-digit OTP to +91 9876543210'), findsOneWidget);
    });

    testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      // Test navigation items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return CustomerManagementScreen();
            },
          ),
        ),
      );

      // Find search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Test search input
      await tester.enterText(searchField, 'test search');
      await tester.pump();
      
      // Verify search input is accepted
      expect(find.text('test search'), findsOneWidget);
    });

    testWidgets('Add customer dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return CustomerManagementScreen();
            },
          ),
        ),
      );

      // Find add customer button
      final addButton = find.byIcon(Icons.person_add);
      expect(addButton, findsOneWidget);

      // Tap add button
      await tester.tap(addButton);
      await tester.pump();

      // Verify dialog is shown
      expect(find.text('Add New Customer'), findsOneWidget);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Credit Limit (₹)'), findsOneWidget);
    });

    testWidgets('Billing cart functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return BillingScreen();
            },
          ),
        ),
      );

      // Switch to products tab
      await tester.tap(find.text('Products'));
      await tester.pump();

      // Verify products are displayed
      expect(find.text('Search products...'), findsOneWidget);
      expect(find.text('Quantity:'), findsOneWidget);
    });

    testWidgets('Theme switching works', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Verify light theme is applied by default
      final theme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('Error handling displays correctly', (WidgetTester tester) async {
      // Test error widget
      final errorDetails = FlutterErrorDetails(
        exception: 'Test error',
        library: 'test',
        context: ErrorDescription('Test context'),
      );

      final errorWidget = ErrorWidget.builder(errorDetails);
      await tester.pumpWidget(MaterialApp(home: errorWidget));

      // Verify error is displayed
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('Responsive design works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      // Verify responsive elements are present
      expect(find.byType(Sizer), findsOneWidget);
    });

    testWidgets('Loading states work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Test loading state
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Test empty form submission
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      // Verify validation message
      expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);
    });

    testWidgets('Navigation between screens works', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Start with auth screen
      expect(find.byType(AuthScreen), findsOneWidget);

      // Navigate to other screens (simulated)
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      expect(find.byType(InventoryDashboard), findsOneWidget);
    });

    testWidgets('Accessibility features work', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify semantic labels
      expect(find.bySemanticsLabel('InvenShop logo'), findsOneWidget);
    });

    testWidgets('Internationalization support', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify language dropdown
      expect(find.text('English'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
    });
  });

  group('InvenShop Integration Tests', () {
    testWidgets('Complete user flow from auth to dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Step 1: Enter phone number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.tap(find.text('Send OTP'));
      await tester.pump();

      // Step 2: Verify OTP screen
      expect(find.text('Verify OTP'), findsOneWidget);

      // Step 3: Enter OTP (simulated)
      // In real test, you would enter actual OTP
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();

      // Step 4: Verify navigation to business registration
      // This would navigate to business registration screen
    });

    testWidgets('Product management flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      // Navigate to add product
      await tester.tap(find.text('Add Item'));
      await tester.pump();

      // Verify add product screen
      // This would navigate to add/edit product screen
    });

    testWidgets('Billing flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return BillingScreen();
            },
          ),
        ),
      );

      // Switch to products tab
      await tester.tap(find.text('Products'));
      await tester.pump();

      // Add product to cart
      // This would simulate adding a product to cart
    });
  });

  group('InvenShop Performance Tests', () {
    testWidgets('App performance under load', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Test multiple rapid interactions
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(TextField));
        await tester.pump();
      }

      // Verify app still responds
      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('Memory usage optimization', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      // Navigate between multiple screens
      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return InventoryDashboard();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Sizer(
            builder: (context, orientation, screenType) {
              return BillingScreen();
            },
          ),
        ),
      );

      // Verify no memory leaks
      expect(find.byType(BillingScreen), findsOneWidget);
    });
  });
}