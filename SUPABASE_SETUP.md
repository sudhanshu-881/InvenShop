# InvenShop Supabase Setup Guide

## 🚀 **Complete Supabase Integration for InvenShop**

This guide will help you set up Supabase as the backend for InvenShop, providing real-time database, authentication, and API functionality.

## 📋 **Prerequisites**

- Supabase account (free tier available)
- Flutter development environment
- Basic knowledge of SQL and database concepts

## 🔧 **Step 1: Create Supabase Project**

### **1.1 Sign Up for Supabase**
1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub, Google, or email
4. Verify your email if required

### **1.2 Create New Project**
1. Click "New Project"
2. Choose your organization
3. Enter project details:
   - **Name**: `invenshop`
   - **Database Password**: Generate a strong password
   - **Region**: Choose closest to your users (e.g., `Asia Pacific (Mumbai)`)
4. Click "Create new project"
5. Wait for project to be ready (2-3 minutes)

## 🗄️ **Step 2: Database Setup**

### **2.1 Access SQL Editor**
1. In your Supabase dashboard, go to "SQL Editor"
2. Click "New query"

### **2.2 Run Database Schema**
1. Copy the entire content from `supabase_schema.sql`
2. Paste it into the SQL editor
3. Click "Run" to execute the schema
4. Wait for all tables, functions, and policies to be created

### **2.3 Verify Database Setup**
1. Go to "Table Editor"
2. You should see the following tables:
   - `shops`
   - `categories`
   - `products`
   - `customers`
   - `transactions`
   - `transaction_items`
   - `staff`
   - `notifications`
   - `analytics_events`

## 🔐 **Step 3: Authentication Setup**

### **3.1 Configure Phone Authentication**
1. Go to "Authentication" → "Settings"
2. Scroll down to "Phone Auth"
3. Enable "Enable phone confirmations"
4. Configure SMS provider (Twilio recommended):
   - Go to "Authentication" → "Providers"
   - Click "Phone"
   - Enable "Enable phone confirmations"
   - Add your Twilio credentials

### **3.2 Configure Twilio (Optional but Recommended)**
1. Sign up for [Twilio](https://twilio.com)
2. Get your Account SID and Auth Token
3. Purchase a phone number
4. In Supabase, go to "Authentication" → "Providers" → "Phone"
5. Add Twilio credentials:
   - **Account SID**: Your Twilio Account SID
   - **Auth Token**: Your Twilio Auth Token
   - **Phone Number**: Your Twilio phone number

## 🔑 **Step 4: Get API Keys**

### **4.1 Get Project URL and API Key**
1. Go to "Settings" → "API"
2. Copy the following values:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### **4.2 Create Environment File**
1. Create `.env` file in your project root
2. Add the following content:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## 📱 **Step 5: Flutter Integration**

### **5.1 Update Dependencies**
The following dependencies are already added to `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.2
  flutter_dotenv: ^5.1.0
  cached_network_image: ^3.3.0
  dio: ^5.3.3
  shared_preferences: ^2.2.2
```

### **5.2 Initialize Supabase**
Supabase is already initialized in `main.dart`:
```dart
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // ... rest of your app initialization
}
```

### **5.3 Use Supabase Services**
The following services are available:
- `AuthService` - Authentication and user management
- `ProductService` - Product CRUD operations
- `CustomerService` - Customer management
- `TransactionService` - Billing and transactions
- `DashboardService` - Analytics and statistics
- `CategoryService` - Category management

## 🔒 **Step 6: Security Configuration**

### **6.1 Row Level Security (RLS)**
RLS is already configured in the schema. This ensures:
- Users can only access their own shop's data
- Data is automatically filtered by shop_id
- Secure multi-tenant architecture

### **6.2 API Security**
1. Go to "Settings" → "API"
2. Configure CORS settings:
   - Add your app domains
   - Enable credentials if needed
3. Set up rate limiting if required

## 📊 **Step 7: Real-time Features**

### **7.1 Enable Real-time**
1. Go to "Database" → "Replication"
2. Enable real-time for tables you want to sync:
   - `products` - For inventory updates
   - `transactions` - For sales updates
   - `customers` - For customer updates

### **7.2 Subscribe to Changes**
```dart
// Example: Listen to product changes
final subscription = SupabaseService.client
  .from('products')
  .stream(primaryKey: ['id'])
  .eq('shop_id', shopId)
  .listen((data) {
    // Handle real-time updates
    print('Products updated: $data');
  });
```

## 🧪 **Step 8: Testing**

### **8.1 Test Authentication**
```dart
// Test phone OTP login
final authService = AuthService();
await authService.signInWithPhone('9876543210');
// Check your phone for OTP
await authService.verifyOTP('9876543210', '123456');
```

### **8.2 Test Database Operations**
```dart
// Test product operations
final productService = ProductService();
await productService.addProduct({
  'name': 'Test Product',
  'price': 100.0,
  'current_stock': 50,
  'min_stock': 10,
  'category_id': 'category-uuid',
});
```

## 🚀 **Step 9: Production Deployment**

### **9.1 Environment Configuration**
1. Create production environment file
2. Use production Supabase project
3. Configure production API keys
4. Set up proper CORS settings

### **9.2 Database Optimization**
1. Monitor query performance
2. Add indexes as needed
3. Set up database backups
4. Configure connection pooling

### **9.3 Security Hardening**
1. Review RLS policies
2. Set up API rate limiting
3. Configure proper CORS
4. Enable audit logging

## 📈 **Step 10: Monitoring and Analytics**

### **10.1 Supabase Dashboard**
- Monitor database performance
- View API usage statistics
- Check authentication metrics
- Review error logs

### **10.2 Custom Analytics**
```dart
// Track custom events
final analyticsService = AnalyticsService();
await analyticsService.trackEvent('product_added', {
  'product_name': 'Test Product',
  'category': 'Grocery',
});
```

## 🔧 **Troubleshooting**

### **Common Issues**

#### **1. Authentication Errors**
- Check phone number format (+91 prefix)
- Verify Twilio configuration
- Check OTP expiration time

#### **2. Database Connection Issues**
- Verify API keys
- Check network connectivity
- Review RLS policies

#### **3. Real-time Not Working**
- Enable real-time for specific tables
- Check subscription filters
- Verify user permissions

### **Debug Mode**
Enable debug logging:
```dart
// In main.dart
Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  debug: true, // Enable debug mode
);
```

## 📚 **Additional Resources**

### **Documentation**
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Supabase Database Guide](https://supabase.com/docs/guides/database)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

### **Community**
- [Supabase Discord](https://discord.supabase.com)
- [GitHub Discussions](https://github.com/supabase/supabase/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/supabase)

## 🎯 **Next Steps**

1. **Complete Setup**: Follow all steps above
2. **Test Integration**: Verify all services work
3. **Customize**: Modify schema for your needs
4. **Deploy**: Set up production environment
5. **Monitor**: Track performance and usage

---

**Your InvenShop app is now powered by Supabase with real-time capabilities, secure authentication, and scalable database infrastructure!** 🚀

**Key Benefits:**
- ✅ **Real-time sync** across devices
- ✅ **Secure authentication** with phone OTP
- ✅ **Scalable database** with automatic backups
- ✅ **Row-level security** for multi-tenant architecture
- ✅ **Built-in analytics** and monitoring
- ✅ **Easy deployment** and maintenance