-- InvenShop Supabase Database Schema
-- This file contains the complete database schema for InvenShop

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'upi', 'credit', 'wallet');
CREATE TYPE transaction_status AS ENUM ('pending', 'completed', 'cancelled', 'refunded');
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'staff');

-- Shops table (extends auth.users)
CREATE TABLE shops (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  address TEXT,
  gst_number TEXT,
  phone TEXT,
  email TEXT,
  description TEXT,
  logo_url TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#2E7D32',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shop_id, name)
);

-- Products table
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT,
  barcode TEXT,
  price DECIMAL(10,2) NOT NULL,
  cost_price DECIMAL(10,2),
  current_stock INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 0,
  max_stock INTEGER DEFAULT 0,
  unit TEXT DEFAULT 'pcs',
  supplier TEXT,
  expiry_date DATE,
  images JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT TRUE,
  is_marketplace_visible BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shop_id, sku),
  UNIQUE(shop_id, barcode)
);

-- Customers table
CREATE TABLE customers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  credit_limit DECIMAL(10,2) DEFAULT 0,
  credit_due DECIMAL(10,2) DEFAULT 0,
  notes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shop_id, phone)
);

-- Transactions table
CREATE TABLE transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  transaction_number TEXT NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  gst_amount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  paid_amount DECIMAL(10,2) NOT NULL,
  payment_method payment_method NOT NULL,
  status transaction_status DEFAULT 'completed',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shop_id, transaction_number)
);

-- Transaction items table
CREATE TABLE transaction_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Staff table (for multi-user support)
CREATE TABLE staff (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  role user_role DEFAULT 'staff',
  permissions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(shop_id, user_id)
);

-- Notifications table
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info',
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics events table
CREATE TABLE analytics_events (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL,
  event_data JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_products_shop_id ON products(shop_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_low_stock ON products(shop_id) WHERE current_stock <= min_stock;

CREATE INDEX idx_customers_shop_id ON customers(shop_id);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_credit_due ON customers(shop_id) WHERE credit_due > 0;

CREATE INDEX idx_transactions_shop_id ON transactions(shop_id);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_transaction_number ON transactions(transaction_number);

CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product_id ON transaction_items(product_id);

CREATE INDEX idx_categories_shop_id ON categories(shop_id);
CREATE INDEX idx_staff_shop_id ON staff(shop_id);
CREATE INDEX idx_notifications_shop_id ON notifications(shop_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_analytics_events_shop_id ON analytics_events(shop_id);

-- Create functions for common operations

-- Function to generate transaction number
CREATE OR REPLACE FUNCTION generate_transaction_number(shop_uuid UUID)
RETURNS TEXT AS $$
DECLARE
  next_number INTEGER;
  transaction_number TEXT;
BEGIN
  -- Get the next transaction number for this shop
  SELECT COALESCE(MAX(CAST(SUBSTRING(transaction_number FROM 'TXN-(\d+)') AS INTEGER)), 0) + 1
  INTO next_number
  FROM transactions
  WHERE shop_id = shop_uuid
  AND transaction_number ~ '^TXN-\d+$';
  
  -- Format as TXN-000001, TXN-000002, etc.
  transaction_number := 'TXN-' || LPAD(next_number::TEXT, 6, '0');
  
  RETURN transaction_number;
END;
$$ LANGUAGE plpgsql;

-- Function to decrease product stock
CREATE OR REPLACE FUNCTION decrease_product_stock(product_uuid UUID, quantity_to_decrease INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE products
  SET current_stock = current_stock - quantity_to_decrease,
      updated_at = NOW()
  WHERE id = product_uuid
  AND current_stock >= quantity_to_decrease;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Insufficient stock for product %', product_uuid;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to create transaction with items
CREATE OR REPLACE FUNCTION create_transaction(
  p_shop_id UUID,
  p_customer_id UUID DEFAULT NULL,
  p_items JSONB,
  p_payment_method payment_method,
  p_paid_amount DECIMAL(10,2),
  p_discount_amount DECIMAL(10,2) DEFAULT 0,
  p_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  transaction_id UUID;
  transaction_number TEXT;
  subtotal DECIMAL(10,2) := 0;
  gst_amount DECIMAL(10,2);
  total_amount DECIMAL(10,2);
  item JSONB;
  item_total DECIMAL(10,2);
BEGIN
  -- Generate transaction number
  transaction_number := generate_transaction_number(p_shop_id);
  
  -- Calculate subtotal
  FOR item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    item_total := (item->>'price')::DECIMAL(10,2) * (item->>'quantity')::INTEGER;
    subtotal := subtotal + item_total;
  END LOOP;
  
  -- Calculate GST (18%)
  gst_amount := subtotal * 0.18;
  
  -- Calculate total
  total_amount := subtotal + gst_amount - p_discount_amount;
  
  -- Create transaction
  INSERT INTO transactions (
    shop_id, customer_id, transaction_number, subtotal, 
    discount_amount, gst_amount, total_amount, paid_amount, 
    payment_method, notes
  ) VALUES (
    p_shop_id, p_customer_id, transaction_number, subtotal,
    p_discount_amount, gst_amount, total_amount, p_paid_amount,
    p_payment_method, p_notes
  ) RETURNING id INTO transaction_id;
  
  -- Create transaction items and update stock
  FOR item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    -- Insert transaction item
    INSERT INTO transaction_items (transaction_id, product_id, quantity, price, total)
    VALUES (
      transaction_id,
      (item->>'product_id')::UUID,
      (item->>'quantity')::INTEGER,
      (item->>'price')::DECIMAL(10,2),
      (item->>'price')::DECIMAL(10,2) * (item->>'quantity')::INTEGER
    );
    
    -- Update product stock
    PERFORM decrease_product_stock(
      (item->>'product_id')::UUID,
      (item->>'quantity')::INTEGER
    );
  END LOOP;
  
  -- Update customer credit if payment method is credit
  IF p_payment_method = 'credit' AND p_customer_id IS NOT NULL THEN
    UPDATE customers
    SET credit_due = credit_due + total_amount,
        updated_at = NOW()
    WHERE id = p_customer_id;
  END IF;
  
  RETURN jsonb_build_object(
    'transaction_id', transaction_id,
    'transaction_number', transaction_number,
    'subtotal', subtotal,
    'gst_amount', gst_amount,
    'total_amount', total_amount
  );
END;
$$ LANGUAGE plpgsql;

-- Function to get dashboard stats
CREATE OR REPLACE FUNCTION get_dashboard_stats(shop_uuid UUID)
RETURNS JSONB AS $$
DECLARE
  today_sales DECIMAL(10,2) := 0;
  yesterday_sales DECIMAL(10,2) := 0;
  total_products INTEGER := 0;
  low_stock_items INTEGER := 0;
  credit_dues DECIMAL(10,2) := 0;
  sales_growth DECIMAL(5,2) := 0;
BEGIN
  -- Get today's sales
  SELECT COALESCE(SUM(total_amount), 0)
  INTO today_sales
  FROM transactions
  WHERE shop_id = shop_uuid
  AND DATE(created_at) = CURRENT_DATE;
  
  -- Get yesterday's sales
  SELECT COALESCE(SUM(total_amount), 0)
  INTO yesterday_sales
  FROM transactions
  WHERE shop_id = shop_uuid
  AND DATE(created_at) = CURRENT_DATE - INTERVAL '1 day';
  
  -- Get total products
  SELECT COUNT(*)
  INTO total_products
  FROM products
  WHERE shop_id = shop_uuid
  AND is_active = TRUE;
  
  -- Get low stock items
  SELECT COUNT(*)
  INTO low_stock_items
  FROM products
  WHERE shop_id = shop_uuid
  AND current_stock <= min_stock
  AND is_active = TRUE;
  
  -- Get credit dues
  SELECT COALESCE(SUM(credit_due), 0)
  INTO credit_dues
  FROM customers
  WHERE shop_id = shop_uuid
  AND is_active = TRUE;
  
  -- Calculate sales growth
  IF yesterday_sales > 0 THEN
    sales_growth := ((today_sales - yesterday_sales) / yesterday_sales) * 100;
  END IF;
  
  RETURN jsonb_build_object(
    'today_sales', today_sales,
    'yesterday_sales', yesterday_sales,
    'total_products', total_products,
    'low_stock_items', low_stock_items,
    'credit_dues', credit_dues,
    'sales_growth', sales_growth
  );
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_shops_updated_at BEFORE UPDATE ON shops
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_updated_at BEFORE UPDATE ON staff
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies for shops
CREATE POLICY "Users can view their own shop" ON shops
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own shop" ON shops
  FOR UPDATE USING (auth.uid() = id);

-- RLS Policies for categories
CREATE POLICY "Users can view categories of their shop" ON categories
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert categories for their shop" ON categories
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "Users can update categories of their shop" ON categories
  FOR UPDATE USING (auth.uid() = shop_id);

CREATE POLICY "Users can delete categories of their shop" ON categories
  FOR DELETE USING (auth.uid() = shop_id);

-- RLS Policies for products
CREATE POLICY "Users can view products of their shop" ON products
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert products for their shop" ON products
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "Users can update products of their shop" ON products
  FOR UPDATE USING (auth.uid() = shop_id);

CREATE POLICY "Users can delete products of their shop" ON products
  FOR DELETE USING (auth.uid() = shop_id);

-- RLS Policies for customers
CREATE POLICY "Users can view customers of their shop" ON customers
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert customers for their shop" ON customers
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "Users can update customers of their shop" ON customers
  FOR UPDATE USING (auth.uid() = shop_id);

CREATE POLICY "Users can delete customers of their shop" ON customers
  FOR DELETE USING (auth.uid() = shop_id);

-- RLS Policies for transactions
CREATE POLICY "Users can view transactions of their shop" ON transactions
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert transactions for their shop" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "Users can update transactions of their shop" ON transactions
  FOR UPDATE USING (auth.uid() = shop_id);

-- RLS Policies for transaction_items
CREATE POLICY "Users can view transaction items of their shop" ON transaction_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM transactions 
      WHERE transactions.id = transaction_items.transaction_id 
      AND transactions.shop_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert transaction items for their shop" ON transaction_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM transactions 
      WHERE transactions.id = transaction_items.transaction_id 
      AND transactions.shop_id = auth.uid()
    )
  );

-- RLS Policies for staff
CREATE POLICY "Users can view staff of their shop" ON staff
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert staff for their shop" ON staff
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

CREATE POLICY "Users can update staff of their shop" ON staff
  FOR UPDATE USING (auth.uid() = shop_id);

-- RLS Policies for notifications
CREATE POLICY "Users can view notifications of their shop" ON notifications
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert notifications for their shop" ON notifications
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

-- RLS Policies for analytics_events
CREATE POLICY "Users can view analytics events of their shop" ON analytics_events
  FOR SELECT USING (auth.uid() = shop_id);

CREATE POLICY "Users can insert analytics events for their shop" ON analytics_events
  FOR INSERT WITH CHECK (auth.uid() = shop_id);

-- Insert default categories for new shops
CREATE OR REPLACE FUNCTION create_default_categories()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO categories (shop_id, name, description, color) VALUES
    (NEW.id, 'Grocery', 'Food and grocery items', '#4CAF50'),
    (NEW.id, 'Beverages', 'Drinks and beverages', '#2196F3'),
    (NEW.id, 'Snacks', 'Snacks and confectionery', '#FF9800'),
    (NEW.id, 'Personal Care', 'Personal care products', '#E91E63'),
    (NEW.id, 'Household', 'Household items', '#9C27B0'),
    (NEW.id, 'Others', 'Other miscellaneous items', '#607D8B');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_default_categories_trigger
  AFTER INSERT ON shops
  FOR EACH ROW EXECUTE FUNCTION create_default_categories();