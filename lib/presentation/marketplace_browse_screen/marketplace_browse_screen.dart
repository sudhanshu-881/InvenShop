import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/app_export.dart';
import './widgets/category_chip_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/sort_options_widget.dart';

class MarketplaceBrowseScreen extends StatefulWidget {
  const MarketplaceBrowseScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceBrowseScreen> createState() =>
      _MarketplaceBrowseScreenState();
}

class _MarketplaceBrowseScreenState extends State<MarketplaceBrowseScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();

  late TabController _tabController;

  int _currentTabIndex = 1; // Browse tab active
  String _selectedCategory = 'All';
  String _currentSort = 'distance';
  Map<String, dynamic> _currentFilters = {};
  bool _isListening = false;
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  String _currentLocation = 'Detecting location...';

  // Mock data for products
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "name": "Fresh Organic Apples",
      "price": "\$4.99/kg",
      "image":
          "https://images.unsplash.com/photo-1720735769578-652c67c25b96",
      "semanticLabel":
          "Fresh red apples arranged in a wooden crate at a farmer's market",
      "shopkeeper": "Green Valley Farm",
      "distance": "0.8 km",
      "rating": 4.8,
      "category": "Groceries",
      "availability": "in_stock",
      "stock": 25,
    },
    {
      "id": 2,
      "name": "Handmade Ceramic Mug",
      "price": "\$12.99",
      "image":
          "https://images.unsplash.com/photo-1697065686935-2779af5cbddc",
      "semanticLabel":
          "White ceramic coffee mug with smooth finish on wooden table",
      "shopkeeper": "Artisan Crafts Co.",
      "distance": "1.2 km",
      "rating": 4.6,
      "category": "Home & Garden",
      "availability": "in_stock",
      "stock": 8,
    },
    {
      "id": 3,
      "name": "Cotton T-Shirt",
      "price": "\$19.99",
      "image":
          "https://images.unsplash.com/photo-1666358070734-b9d6590278c9",
      "semanticLabel": "Navy blue cotton t-shirt laid flat on white background",
      "shopkeeper": "Fashion Hub",
      "distance": "2.1 km",
      "rating": 4.3,
      "category": "Clothing",
      "availability": "low_stock",
      "stock": 3,
    },
    {
      "id": 4,
      "name": "Wireless Bluetooth Headphones",
      "price": "\$89.99",
      "image":
          "https://images.unsplash.com/photo-1670270813556-7e296e7d9f86",
      "semanticLabel":
          "Black wireless headphones with padded ear cups on white surface",
      "shopkeeper": "Tech World",
      "distance": "1.5 km",
      "rating": 4.7,
      "category": "Electronics",
      "availability": "in_stock",
      "stock": 12,
    },
    {
      "id": 5,
      "name": "Artisan Sourdough Bread",
      "price": "\$6.50",
      "image":
          "https://images.unsplash.com/photo-1589569444349-4dbaca268a47",
      "semanticLabel":
          "Rustic sourdough bread loaf with golden crust on wooden cutting board",
      "shopkeeper": "Local Bakery",
      "distance": "0.5 km",
      "rating": 4.9,
      "category": "Food & Beverages",
      "availability": "in_stock",
      "stock": 15,
    },
    {
      "id": 6,
      "name": "Succulent Plant Collection",
      "price": "\$24.99",
      "image":
          "https://images.unsplash.com/photo-1535246750130-80651d8179a3",
      "semanticLabel":
          "Small succulent plants in terracotta pots arranged on wooden shelf",
      "shopkeeper": "Garden Paradise",
      "distance": "3.2 km",
      "rating": 4.4,
      "category": "Home & Garden",
      "availability": "in_stock",
      "stock": 20,
    },
  ];

  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Food & Beverages',
    'Books',
    'Sports',
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _filteredProducts = List.from(_allProducts);
    _initializeLocation();
    _initializeSpeech();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();
    setState(() {
      _hasLocationPermission = status.isGranted;
      _currentLocation = _hasLocationPermission
          ? 'Downtown, City Center'
          : 'Location access denied';
    });
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Simulate loading more products
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  void _filterProducts() {
    List<Map<String, dynamic>> filtered = List.from(_allProducts);

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where(
              (product) => (product['category'] as String) == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((product) =>
              (product['name'] as String).toLowerCase().contains(query) ||
              (product['shopkeeper'] as String).toLowerCase().contains(query))
          .toList();
    }

    // Apply additional filters
    if (_currentFilters.isNotEmpty) {
      // Distance filter
      if (_currentFilters['distance'] != null) {
        final maxDistance = _currentFilters['distance'] as double;
        filtered = filtered.where((product) {
          final distance = double.tryParse(
                  (product['distance'] as String).replaceAll(' km', '')) ??
              0;
          return distance <= maxDistance;
        }).toList();
      }

      // Price filter
      if (_currentFilters['minPrice'] != null &&
          _currentFilters['maxPrice'] != null) {
        final minPrice = _currentFilters['minPrice'] as double;
        final maxPrice = _currentFilters['maxPrice'] as double;
        filtered = filtered.where((product) {
          final priceStr =
              (product['price'] as String).replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.tryParse(priceStr) ?? 0;
          return price >= minPrice && price <= maxPrice;
        }).toList();
      }

      // Availability filter
      if (_currentFilters['availability'] != null &&
          _currentFilters['availability'] != 'all') {
        filtered = filtered
            .where((product) =>
                (product['availability'] as String) ==
                _currentFilters['availability'])
            .toList();
      }

      // Rating filter
      if (_currentFilters['minRating'] != null) {
        final minRating = _currentFilters['minRating'] as double;
        filtered = filtered
            .where((product) => (product['rating'] as double) >= minRating)
            .toList();
      }
    }

    // Sort products
    _sortProducts(filtered);

    setState(() => _filteredProducts = filtered);
  }

  void _sortProducts(List<Map<String, dynamic>> products) {
    switch (_currentSort) {
      case 'distance':
        products.sort((a, b) {
          final distanceA = double.tryParse(
                  (a['distance'] as String).replaceAll(' km', '')) ??
              0;
          final distanceB = double.tryParse(
                  (b['distance'] as String).replaceAll(' km', '')) ??
              0;
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'price_low':
        products.sort((a, b) {
          final priceA = double.tryParse(
                  (a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          final priceB = double.tryParse(
                  (b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        products.sort((a, b) {
          final priceA = double.tryParse(
                  (a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          final priceB = double.tryParse(
                  (b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
              0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'rating':
        products.sort(
            (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'newest':
        // Keep original order for newest
        break;
    }
  }

  Future<void> _startVoiceSearch() async {
    if (!_speechToText.isAvailable) return;

    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _isListening = false;
        });
        _filterProducts();
      },
    );
  }

  void _stopVoiceSearch() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan Barcode'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                Navigator.pop(context, barcodes.first.rawValue);
              }
            },
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() => _searchController.text = result);
      _filterProducts();
    }
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    _filterProducts();
    setState(() => _isLoading = false);
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() => _currentFilters = filters);
          _filterProducts();
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsWidget(
        currentSort: _currentSort,
        onSortChanged: (sort) {
          setState(() => _currentSort = sort);
          _filterProducts();
        },
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsWidget(
        product: product,
        onAddToWishlist: () => _addToWishlist(product),
        onShare: () => _shareProduct(product),
        onViewProfile: () => _viewShopkeeperProfile(product),
      ),
    );
  }

  void _addToWishlist(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to wishlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${product['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewShopkeeperProfile(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${product['shopkeeper']} profile'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onProductTap(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${product['name']} details'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_currentFilters['distance'] != null &&
        _currentFilters['distance'] != 5.0) count++;
    if (_currentFilters['minPrice'] != null && _currentFilters['minPrice'] != 0)
      count++;
    if (_currentFilters['maxPrice'] != null &&
        _currentFilters['maxPrice'] != 1000) count++;
    if (_currentFilters['availability'] != null &&
        _currentFilters['availability'] != 'all') count++;
    if (_currentFilters['minRating'] != null &&
        _currentFilters['minRating'] != 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse Marketplace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
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
                  _currentLocation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _scanBarcode,
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              size: 24,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products or shops...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          size: 20,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      suffixIcon: _isListening
                          ? Padding(
                              padding: EdgeInsets.all(3.w),
                              child: GestureDetector(
                                onTap: _stopVoiceSearch,
                                child: CustomIconWidget(
                                  iconName: 'mic',
                                  size: 20,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(3.w),
                              child: GestureDetector(
                                onTap: _startVoiceSearch,
                                child: CustomIconWidget(
                                  iconName: 'mic',
                                  size: 20,
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                ),
                              ),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundLight,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                    onChanged: (value) => _filterProducts(),
                  ),
                ),
              ],
            ),
          ),

          // Category Carousel
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final filterCount =
                    category == 'All' ? _getActiveFilterCount() : null;

                return CategoryChipWidget(
                  category: category,
                  isSelected: _selectedCategory == category,
                  filterCount: filterCount,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    _filterProducts();
                  },
                );
              },
            ),
          ),

          // Filter and Sort Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_filteredProducts.length} products found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterModal,
                  icon: CustomIconWidget(
                    iconName: 'filter_list',
                    size: 18,
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                  label: Text(
                    'Filter${_getActiveFilterCount() > 0 ? ' (${_getActiveFilterCount()})' : ''}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                        ),
                  ),
                ),
                SizedBox(width: 2.w),
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: CustomIconWidget(
                    iconName: 'sort',
                    size: 18,
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                  label: Text(
                    'Sort',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(2.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 2.w,
                      ),
                      itemCount:
                          _filteredProducts.length + (_isLoading ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _filteredProducts.length) {
                          return _buildLoadingCard();
                        }

                        final product = _filteredProducts[index];
                        return ProductCardWidget(
                          product: product,
                          onTap: () => _onProductTap(product),
                          onLongPress: () => _showQuickActions(product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() => _currentTabIndex = index);
          // Navigate to different screens based on tab
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/inventory-dashboard');
              break;
            case 1:
              // Current screen - Browse
              break;
            case 2:
              Navigator.pushReplacementNamed(
                  context, '/add-edit-product-screen');
              break;
            case 3:
              Navigator.pushReplacementNamed(
                  context, '/analytics-dashboard-screen');
              break;
            case 4:
              Navigator.pushReplacementNamed(
                  context, '/profile-settings-screen');
              break;
          }
        },
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: _currentTabIndex == 0
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
            text: 'Dashboard',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'explore',
              size: 24,
              color: _currentTabIndex == 1
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
            text: 'Browse',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'add_circle_outline',
              size: 24,
              color: _currentTabIndex == 2
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
            text: 'Add',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'analytics',
              size: 24,
              color: _currentTabIndex == 3
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
            text: 'Analytics',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: _currentTabIndex == 4
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
            ),
            text: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSortOptions,
        child: CustomIconWidget(
          iconName: 'sort',
          size: 24,
          color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              size: 80,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 3.h),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters to find what you\'re looking for.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _currentFilters.clear();
                  _searchController.clear();
                });
                _filterProducts();
              },
              child: Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  height: 1.5.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
