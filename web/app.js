// InvenShop Web App - Complete Application
class InvenShopApp {
    constructor() {
        this.currentUser = null;
        this.products = [];
        this.customers = [];
        this.transactions = [];
        this.categories = [];
        this.isAuthenticated = false;
        this.currentView = 'login';
        
        this.init();
    }

    async init() {
        console.log('🚀 Initializing InvenShop Web App...');
        
        // Check for existing session
        const savedUser = localStorage.getItem('invenshop_user');
        if (savedUser) {
            this.currentUser = JSON.parse(savedUser);
            this.isAuthenticated = true;
            this.showDashboard();
        } else {
            this.showLogin();
        }
        
        // Initialize event listeners
        this.setupEventListeners();
        
        // Load initial data if authenticated
        if (this.isAuthenticated) {
            await this.loadInitialData();
        }
        
        console.log('✅ InvenShop Web App initialized');
    }

    setupEventListeners() {
        // Navigation
        document.addEventListener('click', (e) => {
            if (e.target.matches('[data-action]')) {
                const action = e.target.getAttribute('data-action');
                this.handleAction(action, e.target);
            }
        });

        // Form submissions
        document.addEventListener('submit', (e) => {
            e.preventDefault();
            const form = e.target;
            const formType = form.getAttribute('data-form');
            this.handleFormSubmit(formType, form);
        });

        // Search functionality
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.handleSearch(e.target.value);
            });
        }
    }

    // Authentication Methods
    async handleLogin(phoneNumber) {
        try {
            console.log('📱 Sending OTP to:', phoneNumber);
            
            // Simulate OTP sending
            this.showMessage('OTP sent to +91' + phoneNumber, 'success');
            
            // Show OTP verification form
            this.showOTPVerification(phoneNumber);
            
        } catch (error) {
            console.error('Login error:', error);
            this.showMessage('Failed to send OTP. Please try again.', 'error');
        }
    }

    async verifyOTP(phoneNumber, otp) {
        try {
            // Simulate OTP verification (in real app, verify with backend)
            if (otp === '1234' || otp.length === 4) {
                // Create user session
                this.currentUser = {
                    id: 'user_' + Date.now(),
                    phone: phoneNumber,
                    name: 'Shop Owner',
                    shopName: 'My Shop',
                    createdAt: new Date().toISOString()
                };
                
                this.isAuthenticated = true;
                localStorage.setItem('invenshop_user', JSON.stringify(this.currentUser));
                
                this.showMessage('Login successful! Welcome to InvenShop.', 'success');
                await this.loadInitialData();
                this.showDashboard();
                
            } else {
                this.showMessage('Invalid OTP. Please try again.', 'error');
            }
        } catch (error) {
            console.error('OTP verification error:', error);
            this.showMessage('OTP verification failed. Please try again.', 'error');
        }
    }

    logout() {
        this.currentUser = null;
        this.isAuthenticated = false;
        localStorage.removeItem('invenshop_user');
        this.showLogin();
        this.showMessage('Logged out successfully.', 'info');
    }

    // UI Navigation Methods
    showLogin() {
        this.currentView = 'login';
        // Show the web app interface first
        const webAppInterface = document.getElementById('web-app-interface');
        if (webAppInterface) {
            webAppInterface.style.display = 'block';
        }
        this.renderLogin();
    }

    showOTPVerification(phoneNumber) {
        this.currentView = 'otp';
        // Ensure web app interface is visible
        const webAppInterface = document.getElementById('web-app-interface');
        if (webAppInterface) {
            webAppInterface.style.display = 'block';
        }
        this.renderOTPVerification(phoneNumber);
    }

    showDashboard() {
        this.currentView = 'dashboard';
        // Ensure web app interface is visible
        const webAppInterface = document.getElementById('web-app-interface');
        if (webAppInterface) {
            webAppInterface.style.display = 'block';
        }
        this.renderDashboard();
    }

    showInventory() {
        this.currentView = 'inventory';
        this.renderInventory();
    }

    showCustomers() {
        this.currentView = 'customers';
        this.renderCustomers();
    }

    showTransactions() {
        this.currentView = 'transactions';
        this.renderTransactions();
    }

    showSettings() {
        this.currentView = 'settings';
        this.renderSettings();
    }

    // Data Loading
    async loadInitialData() {
        try {
            // Load sample data
            this.products = this.getSampleProducts();
            this.customers = this.getSampleCustomers();
            this.transactions = this.getSampleTransactions();
            this.categories = this.getSampleCategories();
            
            console.log('📊 Data loaded:', {
                products: this.products.length,
                customers: this.customers.length,
                transactions: this.transactions.length
            });
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // Sample Data
    getSampleProducts() {
        return [
            {
                id: 'prod_1',
                name: 'Rice (Basmati)',
                sku: 'RICE001',
                barcode: '1234567890123',
                category: 'Food Grains',
                currentStock: 50,
                minStock: 10,
                maxStock: 100,
                costPrice: 80,
                sellingPrice: 100,
                unit: 'kg',
                description: 'Premium Basmati Rice',
                image: null,
                createdAt: new Date().toISOString()
            },
            {
                id: 'prod_2',
                name: 'Cooking Oil',
                sku: 'OIL001',
                barcode: '1234567890124',
                category: 'Cooking Essentials',
                currentStock: 25,
                minStock: 5,
                maxStock: 50,
                costPrice: 120,
                sellingPrice: 150,
                unit: 'liter',
                description: 'Refined Sunflower Oil',
                image: null,
                createdAt: new Date().toISOString()
            },
            {
                id: 'prod_3',
                name: 'Wheat Flour',
                sku: 'FLOUR001',
                barcode: '1234567890125',
                category: 'Food Grains',
                currentStock: 8,
                minStock: 10,
                maxStock: 50,
                costPrice: 40,
                sellingPrice: 50,
                unit: 'kg',
                description: 'Whole Wheat Flour',
                image: null,
                createdAt: new Date().toISOString()
            }
        ];
    }

    getSampleCustomers() {
        return [
            {
                id: 'cust_1',
                name: 'Rajesh Kumar',
                phone: '9876543210',
                email: 'rajesh@email.com',
                address: '123 Main Street, Mumbai',
                creditLimit: 5000,
                currentBalance: 1200,
                createdAt: new Date().toISOString()
            },
            {
                id: 'cust_2',
                name: 'Priya Sharma',
                phone: '9876543211',
                email: 'priya@email.com',
                address: '456 Park Avenue, Delhi',
                creditLimit: 3000,
                currentBalance: 0,
                createdAt: new Date().toISOString()
            }
        ];
    }

    getSampleTransactions() {
        return [
            {
                id: 'txn_1',
                customerId: 'cust_1',
                customerName: 'Rajesh Kumar',
                items: [
                    { productId: 'prod_1', name: 'Rice (Basmati)', quantity: 2, price: 100, total: 200 },
                    { productId: 'prod_2', name: 'Cooking Oil', quantity: 1, price: 150, total: 150 }
                ],
                totalAmount: 350,
                paidAmount: 200,
                balanceAmount: 150,
                paymentMethod: 'Cash + Credit',
                status: 'completed',
                createdAt: new Date().toISOString()
            }
        ];
    }

    getSampleCategories() {
        return [
            { id: 'cat_1', name: 'Food Grains', description: 'Rice, Wheat, Pulses' },
            { id: 'cat_2', name: 'Cooking Essentials', description: 'Oil, Spices, Condiments' },
            { id: 'cat_3', name: 'Beverages', description: 'Tea, Coffee, Soft Drinks' },
            { id: 'cat_4', name: 'Snacks', description: 'Biscuits, Chips, Nuts' }
        ];
    }

    // Action Handlers
    handleAction(action, element) {
        switch (action) {
            case 'login':
                const phoneInput = document.getElementById('phoneInput');
                if (phoneInput && phoneInput.value) {
                    this.handleLogin(phoneInput.value);
                }
                break;
            case 'verify-otp':
                const otpInput = document.getElementById('otpInput');
                const phoneNumber = element.getAttribute('data-phone');
                if (otpInput && phoneNumber) {
                    this.verifyOTP(phoneNumber, otpInput.value);
                }
                break;
            case 'logout':
                this.logout();
                break;
            case 'show-dashboard':
                this.showDashboard();
                break;
            case 'show-inventory':
                this.showInventory();
                break;
            case 'show-customers':
                this.showCustomers();
                break;
            case 'show-transactions':
                this.showTransactions();
                break;
            case 'show-settings':
                this.showSettings();
                break;
            case 'add-product':
                this.showAddProductForm();
                break;
            case 'edit-product':
                const productId = element.getAttribute('data-product-id');
                this.showEditProductForm(productId);
                break;
            case 'delete-product':
                const deleteProductId = element.getAttribute('data-product-id');
                this.deleteProduct(deleteProductId);
                break;
            case 'add-customer':
                this.showAddCustomerForm();
                break;
            case 'edit-customer':
                const customerId = element.getAttribute('data-customer-id');
                this.showEditCustomerForm(customerId);
                break;
            case 'delete-customer':
                const deleteCustomerId = element.getAttribute('data-customer-id');
                this.deleteCustomer(deleteCustomerId);
                break;
            case 'new-transaction':
                this.showNewTransactionForm();
                break;
            case 'close-modal':
                this.closeModal();
                break;
        }
    }

    handleFormSubmit(formType, form) {
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());
        
        switch (formType) {
            case 'add-product':
                this.addProduct(data);
                break;
            case 'edit-product':
                this.updateProduct(data);
                break;
            case 'add-customer':
                this.addCustomer(data);
                break;
            case 'edit-customer':
                this.updateCustomer(data);
                break;
            case 'new-transaction':
                this.createTransaction(data);
                break;
        }
    }

    handleSearch(query) {
        if (this.currentView === 'inventory') {
            this.searchProducts(query);
        } else if (this.currentView === 'customers') {
            this.searchCustomers(query);
        }
    }

    // Product Management
    addProduct(data) {
        const product = {
            id: 'prod_' + Date.now(),
            name: data.name,
            sku: data.sku,
            barcode: data.barcode,
            category: data.category,
            currentStock: parseInt(data.currentStock) || 0,
            minStock: parseInt(data.minStock) || 0,
            maxStock: parseInt(data.maxStock) || 0,
            costPrice: parseFloat(data.costPrice) || 0,
            sellingPrice: parseFloat(data.sellingPrice) || 0,
            unit: data.unit,
            description: data.description,
            image: null,
            createdAt: new Date().toISOString()
        };
        
        this.products.push(product);
        this.closeModal();
        this.renderInventory();
        this.showMessage('Product added successfully!', 'success');
    }

    updateProduct(data) {
        const productIndex = this.products.findIndex(p => p.id === data.productId);
        if (productIndex !== -1) {
            this.products[productIndex] = {
                ...this.products[productIndex],
                name: data.name,
                sku: data.sku,
                barcode: data.barcode,
                category: data.category,
                currentStock: parseInt(data.currentStock),
                minStock: parseInt(data.minStock),
                maxStock: parseInt(data.maxStock),
                costPrice: parseFloat(data.costPrice),
                sellingPrice: parseFloat(data.sellingPrice),
                unit: data.unit,
                description: data.description
            };
            
            this.closeModal();
            this.renderInventory();
            this.showMessage('Product updated successfully!', 'success');
        }
    }

    deleteProduct(productId) {
        if (confirm('Are you sure you want to delete this product?')) {
            this.products = this.products.filter(p => p.id !== productId);
            this.renderInventory();
            this.showMessage('Product deleted successfully!', 'success');
        }
    }

    searchProducts(query) {
        const filteredProducts = this.products.filter(product => 
            product.name.toLowerCase().includes(query.toLowerCase()) ||
            product.sku.toLowerCase().includes(query.toLowerCase()) ||
            product.barcode.includes(query)
        );
        
        this.renderProductList(filteredProducts);
    }

    // Customer Management
    addCustomer(data) {
        const customer = {
            id: 'cust_' + Date.now(),
            name: data.name,
            phone: data.phone,
            email: data.email,
            address: data.address,
            creditLimit: parseFloat(data.creditLimit) || 0,
            currentBalance: 0,
            createdAt: new Date().toISOString()
        };
        
        this.customers.push(customer);
        this.closeModal();
        this.renderCustomers();
        this.showMessage('Customer added successfully!', 'success');
    }

    updateCustomer(data) {
        const customerIndex = this.customers.findIndex(c => c.id === data.customerId);
        if (customerIndex !== -1) {
            this.customers[customerIndex] = {
                ...this.customers[customerIndex],
                name: data.name,
                phone: data.phone,
                email: data.email,
                address: data.address,
                creditLimit: parseFloat(data.creditLimit)
            };
            
            this.closeModal();
            this.renderCustomers();
            this.showMessage('Customer updated successfully!', 'success');
        }
    }

    deleteCustomer(customerId) {
        if (confirm('Are you sure you want to delete this customer?')) {
            this.customers = this.customers.filter(c => c.id !== customerId);
            this.renderCustomers();
            this.showMessage('Customer deleted successfully!', 'success');
        }
    }

    searchCustomers(query) {
        const filteredCustomers = this.customers.filter(customer => 
            customer.name.toLowerCase().includes(query.toLowerCase()) ||
            customer.phone.includes(query) ||
            customer.email.toLowerCase().includes(query.toLowerCase())
        );
        
        this.renderCustomerList(filteredCustomers);
    }

    // Transaction Management
    createTransaction(data) {
        // This would be more complex in a real app
        const transaction = {
            id: 'txn_' + Date.now(),
            customerId: data.customerId,
            customerName: data.customerName,
            items: JSON.parse(data.items || '[]'),
            totalAmount: parseFloat(data.totalAmount) || 0,
            paidAmount: parseFloat(data.paidAmount) || 0,
            balanceAmount: parseFloat(data.balanceAmount) || 0,
            paymentMethod: data.paymentMethod,
            status: 'completed',
            createdAt: new Date().toISOString()
        };
        
        this.transactions.push(transaction);
        this.closeModal();
        this.renderTransactions();
        this.showMessage('Transaction created successfully!', 'success');
    }

    // UI Rendering Methods
    renderLogin() {
        console.log('🔐 Rendering login form...');
        const appContainer = document.getElementById('web-app-interface');
        if (!appContainer) {
            console.error('❌ Web app interface container not found!');
            return;
        }
        console.log('✅ Web app interface container found, rendering login...');
        appContainer.innerHTML = `
            <div class="login-container">
                <div class="login-card">
                    <div class="login-header">
                        <h1>🏪 InvenShop</h1>
                        <p>Your Digital Shop Assistant</p>
                    </div>
                    
                    <form data-form="login" class="login-form">
                        <div class="form-group">
                            <label for="phoneInput">Mobile Number</label>
                            <div class="phone-input">
                                <span class="country-code">+91</span>
                                <input type="tel" id="phoneInput" name="phone" placeholder="Enter 10-digit mobile number" required maxlength="10">
                            </div>
                        </div>
                        
                        <button type="submit" data-action="login" class="btn btn-primary">
                            Send OTP
                        </button>
                    </form>
                    
                    <div class="login-footer">
                        <p>By continuing, you agree to our Terms of Service</p>
                    </div>
                </div>
            </div>
        `;
    }

    renderOTPVerification(phoneNumber) {
        const appContainer = document.getElementById('web-app-interface');
        appContainer.innerHTML = `
            <div class="otp-container">
                <div class="otp-card">
                    <div class="otp-header">
                        <h1>📱 Verify OTP</h1>
                        <p>Enter the OTP sent to +91${phoneNumber}</p>
                    </div>
                    
                    <form data-form="otp-verification" class="otp-form">
                        <div class="form-group">
                            <label for="otpInput">OTP Code</label>
                            <input type="text" id="otpInput" name="otp" placeholder="Enter 4-digit OTP" required maxlength="4" pattern="[0-9]{4}">
                        </div>
                        
                        <button type="submit" data-action="verify-otp" data-phone="${phoneNumber}" class="btn btn-primary">
                            Verify OTP
                        </button>
                        
                        <button type="button" data-action="resend-otp" class="btn btn-link">
                            Resend OTP
                        </button>
                    </form>
                </div>
            </div>
        `;
    }

    renderDashboard() {
        const appContainer = document.getElementById('web-app-interface');
        const totalProducts = this.products.length;
        const lowStockProducts = this.products.filter(p => p.currentStock <= p.minStock).length;
        const totalCustomers = this.customers.length;
        const totalTransactions = this.transactions.length;
        const totalRevenue = this.transactions.reduce((sum, t) => sum + t.totalAmount, 0);
        
        appContainer.innerHTML = `
            <div class="app-layout">
                <header class="app-header">
                    <div class="header-left">
                        <h1>🏪 InvenShop</h1>
                        <span class="user-info">Welcome, ${this.currentUser.name}</span>
                    </div>
                    <div class="header-right">
                        <button data-action="show-settings" class="btn btn-icon">⚙️</button>
                        <button data-action="logout" class="btn btn-outline">Logout</button>
                    </div>
                </header>
                
                <nav class="app-nav">
                    <button data-action="show-dashboard" class="nav-btn active">📊 Dashboard</button>
                    <button data-action="show-inventory" class="nav-btn">📦 Inventory</button>
                    <button data-action="show-customers" class="nav-btn">👥 Customers</button>
                    <button data-action="show-transactions" class="nav-btn">💰 Transactions</button>
                </nav>
                
                <main class="app-main">
                    <div class="dashboard">
                        <h2>Dashboard Overview</h2>
                        
                        <div class="stats-grid">
                            <div class="stat-card">
                                <div class="stat-icon">📦</div>
                                <div class="stat-content">
                                    <h3>${totalProducts}</h3>
                                    <p>Total Products</p>
                                </div>
                            </div>
                            
                            <div class="stat-card ${lowStockProducts > 0 ? 'warning' : ''}">
                                <div class="stat-icon">⚠️</div>
                                <div class="stat-content">
                                    <h3>${lowStockProducts}</h3>
                                    <p>Low Stock Items</p>
                                </div>
                            </div>
                            
                            <div class="stat-card">
                                <div class="stat-icon">👥</div>
                                <div class="stat-content">
                                    <h3>${totalCustomers}</h3>
                                    <p>Total Customers</p>
                                </div>
                            </div>
                            
                            <div class="stat-card">
                                <div class="stat-icon">💰</div>
                                <div class="stat-content">
                                    <h3>₹${totalRevenue.toLocaleString()}</h3>
                                    <p>Total Revenue</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="dashboard-sections">
                            <div class="section">
                                <h3>Recent Products</h3>
                                <div class="product-list">
                                    ${this.products.slice(0, 5).map(product => `
                                        <div class="product-item">
                                            <span class="product-name">${product.name}</span>
                                            <span class="product-stock ${product.currentStock <= product.minStock ? 'low-stock' : ''}">
                                                ${product.currentStock} ${product.unit}
                                            </span>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                            
                            <div class="section">
                                <h3>Recent Transactions</h3>
                                <div class="transaction-list">
                                    ${this.transactions.slice(0, 5).map(transaction => `
                                        <div class="transaction-item">
                                            <span class="transaction-customer">${transaction.customerName}</span>
                                            <span class="transaction-amount">₹${transaction.totalAmount}</span>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    renderInventory() {
        const appContainer = document.getElementById('web-app-interface');
        appContainer.innerHTML = `
            <div class="app-layout">
                <header class="app-header">
                    <div class="header-left">
                        <h1>🏪 InvenShop</h1>
                        <span class="user-info">Inventory Management</span>
                    </div>
                    <div class="header-right">
                        <button data-action="show-settings" class="btn btn-icon">⚙️</button>
                        <button data-action="logout" class="btn btn-outline">Logout</button>
                    </div>
                </header>
                
                <nav class="app-nav">
                    <button data-action="show-dashboard" class="nav-btn">📊 Dashboard</button>
                    <button data-action="show-inventory" class="nav-btn active">📦 Inventory</button>
                    <button data-action="show-customers" class="nav-btn">👥 Customers</button>
                    <button data-action="show-transactions" class="nav-btn">💰 Transactions</button>
                </nav>
                
                <main class="app-main">
                    <div class="inventory">
                        <div class="inventory-header">
                            <h2>Product Inventory</h2>
                            <div class="inventory-actions">
                                <div class="search-box">
                                    <input type="text" id="searchInput" placeholder="Search products...">
                                </div>
                                <button data-action="add-product" class="btn btn-primary">+ Add Product</button>
                            </div>
                        </div>
                        
                        <div class="product-grid" id="productGrid">
                            ${this.renderProductList(this.products)}
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    renderProductList(products) {
        if (products.length === 0) {
            return '<div class="empty-state">No products found. Add your first product to get started!</div>';
        }
        
        return products.map(product => `
            <div class="product-card ${product.currentStock <= product.minStock ? 'low-stock' : ''}">
                <div class="product-header">
                    <h3>${product.name}</h3>
                    <div class="product-actions">
                        <button data-action="edit-product" data-product-id="${product.id}" class="btn btn-sm">✏️</button>
                        <button data-action="delete-product" data-product-id="${product.id}" class="btn btn-sm btn-danger">🗑️</button>
                    </div>
                </div>
                
                <div class="product-details">
                    <p><strong>SKU:</strong> ${product.sku}</p>
                    <p><strong>Category:</strong> ${product.category}</p>
                    <p><strong>Stock:</strong> ${product.currentStock} ${product.unit}</p>
                    <p><strong>Min Stock:</strong> ${product.minStock} ${product.unit}</p>
                    <p><strong>Cost Price:</strong> ₹${product.costPrice}</p>
                    <p><strong>Selling Price:</strong> ₹${product.sellingPrice}</p>
                    ${product.description ? `<p><strong>Description:</strong> ${product.description}</p>` : ''}
                </div>
                
                <div class="product-footer">
                    <span class="stock-status ${product.currentStock <= product.minStock ? 'low' : 'good'}">
                        ${product.currentStock <= product.minStock ? '⚠️ Low Stock' : '✅ In Stock'}
                    </span>
                </div>
            </div>
        `).join('');
    }

    renderCustomers() {
        const appContainer = document.getElementById('web-app-interface');
        appContainer.innerHTML = `
            <div class="app-layout">
                <header class="app-header">
                    <div class="header-left">
                        <h1>🏪 InvenShop</h1>
                        <span class="user-info">Customer Management</span>
                    </div>
                    <div class="header-right">
                        <button data-action="show-settings" class="btn btn-icon">⚙️</button>
                        <button data-action="logout" class="btn btn-outline">Logout</button>
                    </div>
                </header>
                
                <nav class="app-nav">
                    <button data-action="show-dashboard" class="nav-btn">📊 Dashboard</button>
                    <button data-action="show-inventory" class="nav-btn">📦 Inventory</button>
                    <button data-action="show-customers" class="nav-btn active">👥 Customers</button>
                    <button data-action="show-transactions" class="nav-btn">💰 Transactions</button>
                </nav>
                
                <main class="app-main">
                    <div class="customers">
                        <div class="customers-header">
                            <h2>Customer Management</h2>
                            <div class="customers-actions">
                                <div class="search-box">
                                    <input type="text" id="searchInput" placeholder="Search customers...">
                                </div>
                                <button data-action="add-customer" class="btn btn-primary">+ Add Customer</button>
                            </div>
                        </div>
                        
                        <div class="customer-grid" id="customerGrid">
                            ${this.renderCustomerList(this.customers)}
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    renderCustomerList(customers) {
        if (customers.length === 0) {
            return '<div class="empty-state">No customers found. Add your first customer to get started!</div>';
        }
        
        return customers.map(customer => `
            <div class="customer-card">
                <div class="customer-header">
                    <h3>${customer.name}</h3>
                    <div class="customer-actions">
                        <button data-action="edit-customer" data-customer-id="${customer.id}" class="btn btn-sm">✏️</button>
                        <button data-action="delete-customer" data-customer-id="${customer.id}" class="btn btn-sm btn-danger">🗑️</button>
                    </div>
                </div>
                
                <div class="customer-details">
                    <p><strong>Phone:</strong> ${customer.phone}</p>
                    <p><strong>Email:</strong> ${customer.email || 'N/A'}</p>
                    <p><strong>Address:</strong> ${customer.address || 'N/A'}</p>
                    <p><strong>Credit Limit:</strong> ₹${customer.creditLimit}</p>
                    <p><strong>Current Balance:</strong> ₹${customer.currentBalance}</p>
                </div>
                
                <div class="customer-footer">
                    <span class="balance-status ${customer.currentBalance > 0 ? 'pending' : 'clear'}">
                        ${customer.currentBalance > 0 ? '💰 Outstanding: ₹' + customer.currentBalance : '✅ No Outstanding'}
                    </span>
                </div>
            </div>
        `).join('');
    }

    renderTransactions() {
        const appContainer = document.getElementById('web-app-interface');
        appContainer.innerHTML = `
            <div class="app-layout">
                <header class="app-header">
                    <div class="header-left">
                        <h1>🏪 InvenShop</h1>
                        <span class="user-info">Transaction Management</span>
                    </div>
                    <div class="header-right">
                        <button data-action="show-settings" class="btn btn-icon">⚙️</button>
                        <button data-action="logout" class="btn btn-outline">Logout</button>
                    </div>
                </header>
                
                <nav class="app-nav">
                    <button data-action="show-dashboard" class="nav-btn">📊 Dashboard</button>
                    <button data-action="show-inventory" class="nav-btn">📦 Inventory</button>
                    <button data-action="show-customers" class="nav-btn">👥 Customers</button>
                    <button data-action="show-transactions" class="nav-btn active">💰 Transactions</button>
                </nav>
                
                <main class="app-main">
                    <div class="transactions">
                        <div class="transactions-header">
                            <h2>Transaction History</h2>
                            <div class="transactions-actions">
                                <button data-action="new-transaction" class="btn btn-primary">+ New Transaction</button>
                            </div>
                        </div>
                        
                        <div class="transaction-list">
                            ${this.transactions.map(transaction => `
                                <div class="transaction-card">
                                    <div class="transaction-header">
                                        <h3>Transaction #${transaction.id}</h3>
                                        <span class="transaction-date">${new Date(transaction.createdAt).toLocaleDateString()}</span>
                                    </div>
                                    
                                    <div class="transaction-details">
                                        <p><strong>Customer:</strong> ${transaction.customerName}</p>
                                        <p><strong>Total Amount:</strong> ₹${transaction.totalAmount}</p>
                                        <p><strong>Paid Amount:</strong> ₹${transaction.paidAmount}</p>
                                        <p><strong>Balance:</strong> ₹${transaction.balanceAmount}</p>
                                        <p><strong>Payment Method:</strong> ${transaction.paymentMethod}</p>
                                    </div>
                                    
                                    <div class="transaction-items">
                                        <h4>Items:</h4>
                                        ${transaction.items.map(item => `
                                            <div class="transaction-item">
                                                <span>${item.name} x ${item.quantity}</span>
                                                <span>₹${item.total}</span>
                                            </div>
                                        `).join('')}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    renderSettings() {
        const appContainer = document.getElementById('web-app-interface');
        appContainer.innerHTML = `
            <div class="app-layout">
                <header class="app-header">
                    <div class="header-left">
                        <h1>🏪 InvenShop</h1>
                        <span class="user-info">Settings</span>
                    </div>
                    <div class="header-right">
                        <button data-action="show-dashboard" class="btn btn-outline">← Back</button>
                        <button data-action="logout" class="btn btn-outline">Logout</button>
                    </div>
                </header>
                
                <main class="app-main">
                    <div class="settings">
                        <h2>Settings</h2>
                        
                        <div class="settings-section">
                            <h3>Profile Information</h3>
                            <div class="profile-info">
                                <p><strong>Name:</strong> ${this.currentUser.name}</p>
                                <p><strong>Phone:</strong> ${this.currentUser.phone}</p>
                                <p><strong>Shop Name:</strong> ${this.currentUser.shopName}</p>
                            </div>
                        </div>
                        
                        <div class="settings-section">
                            <h3>App Information</h3>
                            <div class="app-info">
                                <p><strong>Version:</strong> 2.0.0</p>
                                <p><strong>Last Updated:</strong> ${new Date().toLocaleDateString()}</p>
                                <p><strong>Total Products:</strong> ${this.products.length}</p>
                                <p><strong>Total Customers:</strong> ${this.customers.length}</p>
                            </div>
                        </div>
                        
                        <div class="settings-section">
                            <h3>Data Management</h3>
                            <div class="data-actions">
                                <button class="btn btn-outline">Export Data</button>
                                <button class="btn btn-outline">Import Data</button>
                                <button class="btn btn-danger">Clear All Data</button>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        `;
    }

    // Modal Management
    showAddProductForm() {
        this.showModal('Add Product', this.getAddProductFormHTML());
    }

    showEditProductForm(productId) {
        const product = this.products.find(p => p.id === productId);
        if (product) {
            this.showModal('Edit Product', this.getEditProductFormHTML(product));
        }
    }

    showAddCustomerForm() {
        this.showModal('Add Customer', this.getAddCustomerFormHTML());
    }

    showEditCustomerForm(customerId) {
        const customer = this.customers.find(c => c.id === customerId);
        if (customer) {
            this.showModal('Edit Customer', this.getEditCustomerFormHTML(customer));
        }
    }

    showNewTransactionForm() {
        this.showModal('New Transaction', this.getNewTransactionFormHTML());
    }

    showModal(title, content) {
        const modalHTML = `
            <div class="modal-overlay" id="modal">
                <div class="modal">
                    <div class="modal-header">
                        <h3>${title}</h3>
                        <button data-action="close-modal" class="btn btn-icon">✕</button>
                    </div>
                    <div class="modal-content">
                        ${content}
                    </div>
                </div>
            </div>
        `;
        
        document.body.insertAdjacentHTML('beforeend', modalHTML);
    }

    closeModal() {
        const modal = document.getElementById('modal');
        if (modal) {
            modal.remove();
        }
    }

    // Form HTML Generators
    getAddProductFormHTML() {
        return `
            <form data-form="add-product" class="form">
                <div class="form-group">
                    <label for="name">Product Name *</label>
                    <input type="text" id="name" name="name" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="sku">SKU *</label>
                        <input type="text" id="sku" name="sku" required>
                    </div>
                    <div class="form-group">
                        <label for="barcode">Barcode</label>
                        <input type="text" id="barcode" name="barcode">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="category">Category *</label>
                    <select id="category" name="category" required>
                        <option value="">Select Category</option>
                        ${this.categories.map(cat => `<option value="${cat.name}">${cat.name}</option>`).join('')}
                    </select>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="currentStock">Current Stock *</label>
                        <input type="number" id="currentStock" name="currentStock" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="unit">Unit *</label>
                        <select id="unit" name="unit" required>
                            <option value="kg">kg</option>
                            <option value="liter">liter</option>
                            <option value="piece">piece</option>
                            <option value="packet">packet</option>
                            <option value="box">box</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="minStock">Min Stock</label>
                        <input type="number" id="minStock" name="minStock" min="0">
                    </div>
                    <div class="form-group">
                        <label for="maxStock">Max Stock</label>
                        <input type="number" id="maxStock" name="maxStock" min="0">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="costPrice">Cost Price *</label>
                        <input type="number" id="costPrice" name="costPrice" step="0.01" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="sellingPrice">Selling Price *</label>
                        <input type="number" id="sellingPrice" name="sellingPrice" step="0.01" min="0" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="3"></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="button" data-action="close-modal" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Product</button>
                </div>
            </form>
        `;
    }

    getEditProductFormHTML(product) {
        return `
            <form data-form="edit-product" class="form">
                <input type="hidden" name="productId" value="${product.id}">
                
                <div class="form-group">
                    <label for="name">Product Name *</label>
                    <input type="text" id="name" name="name" value="${product.name}" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="sku">SKU *</label>
                        <input type="text" id="sku" name="sku" value="${product.sku}" required>
                    </div>
                    <div class="form-group">
                        <label for="barcode">Barcode</label>
                        <input type="text" id="barcode" name="barcode" value="${product.barcode}">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="category">Category *</label>
                    <select id="category" name="category" required>
                        <option value="">Select Category</option>
                        ${this.categories.map(cat => 
                            `<option value="${cat.name}" ${cat.name === product.category ? 'selected' : ''}>${cat.name}</option>`
                        ).join('')}
                    </select>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="currentStock">Current Stock *</label>
                        <input type="number" id="currentStock" name="currentStock" value="${product.currentStock}" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="unit">Unit *</label>
                        <select id="unit" name="unit" required>
                            <option value="kg" ${product.unit === 'kg' ? 'selected' : ''}>kg</option>
                            <option value="liter" ${product.unit === 'liter' ? 'selected' : ''}>liter</option>
                            <option value="piece" ${product.unit === 'piece' ? 'selected' : ''}>piece</option>
                            <option value="packet" ${product.unit === 'packet' ? 'selected' : ''}>packet</option>
                            <option value="box" ${product.unit === 'box' ? 'selected' : ''}>box</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="minStock">Min Stock</label>
                        <input type="number" id="minStock" name="minStock" value="${product.minStock}" min="0">
                    </div>
                    <div class="form-group">
                        <label for="maxStock">Max Stock</label>
                        <input type="number" id="maxStock" name="maxStock" value="${product.maxStock}" min="0">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="costPrice">Cost Price *</label>
                        <input type="number" id="costPrice" name="costPrice" value="${product.costPrice}" step="0.01" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="sellingPrice">Selling Price *</label>
                        <input type="number" id="sellingPrice" name="sellingPrice" value="${product.sellingPrice}" step="0.01" min="0" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="3">${product.description || ''}</textarea>
                </div>
                
                <div class="form-actions">
                    <button type="button" data-action="close-modal" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Product</button>
                </div>
            </form>
        `;
    }

    getAddCustomerFormHTML() {
        return `
            <form data-form="add-customer" class="form">
                <div class="form-group">
                    <label for="name">Customer Name *</label>
                    <input type="text" id="name" name="name" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="creditLimit">Credit Limit (₹)</label>
                    <input type="number" id="creditLimit" name="creditLimit" step="0.01" min="0" value="0">
                </div>
                
                <div class="form-actions">
                    <button type="button" data-action="close-modal" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Customer</button>
                </div>
            </form>
        `;
    }

    getEditCustomerFormHTML(customer) {
        return `
            <form data-form="edit-customer" class="form">
                <input type="hidden" name="customerId" value="${customer.id}">
                
                <div class="form-group">
                    <label for="name">Customer Name *</label>
                    <input type="text" id="name" name="name" value="${customer.name}" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" value="${customer.phone}" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" value="${customer.email || ''}">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" rows="3">${customer.address || ''}</textarea>
                </div>
                
                <div class="form-group">
                    <label for="creditLimit">Credit Limit (₹)</label>
                    <input type="number" id="creditLimit" name="creditLimit" value="${customer.creditLimit}" step="0.01" min="0">
                </div>
                
                <div class="form-actions">
                    <button type="button" data-action="close-modal" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Customer</button>
                </div>
            </form>
        `;
    }

    getNewTransactionFormHTML() {
        return `
            <form data-form="new-transaction" class="form">
                <div class="form-group">
                    <label for="customerId">Customer *</label>
                    <select id="customerId" name="customerId" required>
                        <option value="">Select Customer</option>
                        ${this.customers.map(customer => 
                            `<option value="${customer.id}">${customer.name} (${customer.phone})</option>`
                        ).join('')}
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="items">Items (JSON format)</label>
                    <textarea id="items" name="items" rows="4" placeholder='[{"productId": "prod_1", "name": "Product Name", "quantity": 2, "price": 100, "total": 200}]'></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="totalAmount">Total Amount (₹) *</label>
                        <input type="number" id="totalAmount" name="totalAmount" step="0.01" min="0" required>
                    </div>
                    <div class="form-group">
                        <label for="paidAmount">Paid Amount (₹) *</label>
                        <input type="number" id="paidAmount" name="paidAmount" step="0.01" min="0" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="balanceAmount">Balance Amount (₹)</label>
                    <input type="number" id="balanceAmount" name="balanceAmount" step="0.01" min="0" readonly>
                </div>
                
                <div class="form-group">
                    <label for="paymentMethod">Payment Method *</label>
                    <select id="paymentMethod" name="paymentMethod" required>
                        <option value="Cash">Cash</option>
                        <option value="Credit">Credit</option>
                        <option value="Cash + Credit">Cash + Credit</option>
                        <option value="UPI">UPI</option>
                        <option value="Card">Card</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button type="button" data-action="close-modal" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Transaction</button>
                </div>
            </form>
        `;
    }

    // Utility Methods
    showMessage(message, type = 'info') {
        // Create toast notification
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        
        // Add to page
        document.body.appendChild(toast);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 3000);
    }

    // Initialize the app when DOM is loaded
    static init() {
        document.addEventListener('DOMContentLoaded', () => {
            window.invenShopApp = new InvenShopApp();
        });
    }
}

// Initialize the app when DOM is loaded, but don't auto-start
document.addEventListener('DOMContentLoaded', () => {
    console.log('📱 InvenShop Web App loaded and ready');
    console.log('🌐 Click "Continue on Web" to start the application');
});