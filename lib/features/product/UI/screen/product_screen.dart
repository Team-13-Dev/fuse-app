import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/di/dependency_injection.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';
import 'package:fuse_system/features/product/UI/screen/product_details_screen.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_cubit.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_state.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';
import 'package:fuse_system/features/product/logic/cubit/product_state.dart';

// ─── Products Screen ──────────────────────────────────────────────────────────

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _stockFilter = 'All stock';
  bool _isSearching = false;

  // ✅ FIX: Cache last known products so UI stays visible during loading
  List<ProductResponseModel> _displayedProducts = [];
  bool _isLoadingProducts = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Stats ──

  double _catalogValue(List<ProductResponseModel> products) =>
      products.fold(0, (s, p) => s + (double.tryParse(p.price) ?? 0) * p.stock);

  double _avgMargin(List<ProductResponseModel> products) {
    final withCost = products
        .where((p) => (double.tryParse(p.cost) ?? 0) > 0)
        .toList();
    if (withCost.isEmpty) return 0;
    return withCost.fold(0.0, (s, p) {
          final price = double.tryParse(p.price) ?? 0;
          final cost = double.tryParse(p.cost) ?? 0;
          return s + (price > 0 ? ((price - cost) / price * 100) : 0);
        }) /
        withCost.length;
  }

  int _outOfStock(List<ProductResponseModel> products) =>
      products.where((p) => p.stock == 0).length;

  // ── Stock filter ──

  List<ProductResponseModel> _applyStockFilter(
    List<ProductResponseModel> products,
  ) {
    switch (_stockFilter) {
      case 'Out of stock':
        return products.where((p) => p.stock == 0).toList();
      case 'Low stock':
        return products.where((p) => p.stock > 0 && p.stock <= 10).toList();
      case 'In stock':
        return products.where((p) => p.stock > 10).toList();
      default:
        return products;
    }
  }

  int _outCount(List<ProductResponseModel> products) =>
      products.where((p) => p.stock == 0).length;

  int _lowCount(List<ProductResponseModel> products) =>
      products.where((p) => p.stock > 0 && p.stock <= 10).length;

  int _inCount(List<ProductResponseModel> products) =>
      products.where((p) => p.stock > 10).length;

  // ── Search ──

  void _onSearchChanged(String value) {
    final cubit = context.read<ProductCubit>();
    if (value.trim().isEmpty) {
      setState(() => _isSearching = false);
      cubit.getProducts();
    } else {
      setState(() => _isSearching = true);
      cubit.searchProducts(value);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _stockFilter = 'All stock';
    });
    context.read<ProductCubit>().getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<AddProductCubit>(),
        child: _AddProductSheet(
          onProductAdded: () {
            _clearSearch();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: FuseAppBar(currentPage: 'Products'),
      drawer: const FuseDrawer(activeItem: 'products'),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        // ✅ FIX: BlocConsumer caches products so the search field never disappears
        child: BlocConsumer<ProductCubit, ProductState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () => setState(() => _isLoadingProducts = true),
              success: (products) => setState(() {
                _displayedProducts = products;
                _isLoadingProducts = false;
              }),
              error: (_) => setState(() => _isLoadingProducts = false),
            );
          },
          builder: (context, state) {
            // Full-screen spinner only on very first load (no cached data yet)
            if (_isLoadingProducts &&
                _displayedProducts.isEmpty &&
                !_isSearching) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
              );
            }

            // Show error view only during normal browsing (not while searching)
            return state.maybeWhen(
              error: (errorHandler) => !_isSearching
                  ? _ErrorView(
                      message: errorHandler.apiErrorModel.error,
                      onRetry: () => context.read<ProductCubit>().getProducts(),
                    )
                  : _buildBody(), // ✅ keep body visible on search error
              orElse: () => _buildBody(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    final filtered = _applyStockFilter(_displayedProducts);
    final cubit = context.read<ProductCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _PageHeader(onAdd: _showAddProduct),
          const SizedBox(height: 16),
          _StatsGrid(
            totalProducts: _displayedProducts.length,
            catalogValue: _catalogValue(_displayedProducts),
            avgMargin: _avgMargin(_displayedProducts),
            outOfStock: _outOfStock(_displayedProducts),
          ),
          const SizedBox(height: 16),
          _ProductListCard(
            searchController: _searchController,
            isSearching: _isSearching,
            isLoading: _isLoadingProducts, // ✅ inline loader flag
            stockFilter: _stockFilter,
            products: filtered,
            totalCount: _displayedProducts.length,
            outCount: _outCount(_displayedProducts),
            lowCount: _lowCount(_displayedProducts),
            inCount: _inCount(_displayedProducts),
            currentPage: cubit.currentPage,
            totalPages: cubit.totalPages,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _clearSearch,
            onFilterChanged: (v) => setState(() => _stockFilter = v),
            onStockChipTap: (label) => setState(
              () => _stockFilter = _stockFilter == label ? 'All stock' : label,
            ),
            onPageChanged: (page) => cubit.gotoPage(page),
            onPrevPage: () => cubit.gotoPage(cubit.currentPage - 1),
            onNextPage: () => cubit.gotoPage(cubit.currentPage + 1),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: Color(0xFFA32D2D),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888780)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _PageHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Manage your product catalog, pricing, inventory, and categories.',
          style: TextStyle(fontSize: 12, color: Color(0xFF888780)),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int totalProducts;
  final double catalogValue;
  final double avgMargin;
  final int outOfStock;

  const _StatsGrid({
    required this.totalProducts,
    required this.catalogValue,
    required this.avgMargin,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL\nPRODUCTS',
                value: '$totalProducts',
                icon: Icons.inventory_2_outlined,
                isDark: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'CATALOG\nVALUE',
                value: 'EGP\n${_formatNum(catalogValue)}',
                icon: Icons.attach_money_rounded,
                isDark: false,
                valueStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  height: 1.2,
                ),
                subLabel: 'Price × stock',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'AVG. MARGIN',
                value: '${avgMargin.toStringAsFixed(1)}%',
                icon: Icons.trending_up_rounded,
                isDark: false,
                subLabel: 'Products with cost',
                iconColor: const Color(0xFF3B6D11),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'OUT OF STOCK',
                value: '$outOfStock',
                icon: Icons.warning_amber_rounded,
                isDark: false,
                subLabel: outOfStock == 0 ? 'All stocked' : 'Items',
                iconColor: const Color(0xFFBA7517),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNum(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)},${(v % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    }
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final String? subLabel;
  final TextStyle? valueStyle;
  final Color? iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.subLabel,
    this.valueStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF6C5CE7) : Colors.white;
    final labelClr = isDark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF888780);
    final valClr = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final icClr = isDark
        ? Colors.white.withOpacity(0.5)
        : (iconColor ?? const Color(0xFF6C5CE7));
    final subClr = isDark
        ? Colors.white.withOpacity(0.6)
        : const Color(0xFF888780);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? null
            : Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: labelClr,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: icClr),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: valClr,
                  height: 1.1,
                ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(subLabel!, style: TextStyle(fontSize: 11, color: subClr)),
          ],
        ],
      ),
    );
  }
}

// ─── Product List Card ────────────────────────────────────────────────────────

class _ProductListCard extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final bool isLoading; // ✅ NEW
  final String stockFilter;
  final List<ProductResponseModel> products;
  final int totalCount;
  final int outCount;
  final int lowCount;
  final int inCount;
  final int currentPage;
  final int totalPages;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onStockChipTap;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  const _ProductListCard({
    required this.searchController,
    required this.isSearching,
    required this.isLoading, // ✅ NEW
    required this.stockFilter,
    required this.products,
    required this.totalCount,
    required this.outCount,
    required this.lowCount,
    required this.inCount,
    required this.currentPage,
    required this.totalPages,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
    required this.onStockChipTap,
    required this.onPageChanged,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Text(
                  isSearching
                      ? 'Search results (${products.length})'
                      : 'All products ($totalCount)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                if (isSearching)
                  GestureDetector(
                    onTap: onClearSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Clear search',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888780),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => context.read<ProductCubit>().getProducts(),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Color(0xFF888780),
                    ),
                  ),
              ],
            ),
          ),

          // ── Search + Filter ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB4B2A9),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: Color(0xFFB4B2A9),
                        ),
                        suffixIcon: isSearching
                            ? GestureDetector(
                                onTap: onClearSearch,
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF888780),
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xFF6C5CE7),
                            width: isSearching ? 1.5 : 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterDropdown(value: stockFilter, onChanged: onFilterChanged),
              ],
            ),
          ),

          // ── Search hint banner ──
          if (isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: const [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Color(0xFFB4B2A9),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Results update automatically after you stop typing',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB4B2A9)),
                  ),
                ],
              ),
            ),

          // ── Stock chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                _StockChip(
                  label: 'Out of stock',
                  count: outCount,
                  activeColor: const Color(0xFFA32D2D),
                  activeBg: const Color(0xFFFCEBEB),
                  isActive: stockFilter == 'Out of stock',
                  onTap: () => onStockChipTap('Out of stock'),
                ),
                const SizedBox(width: 6),
                _StockChip(
                  label: 'Low stock',
                  count: lowCount,
                  activeColor: const Color(0xFFBA7517),
                  activeBg: const Color(0xFFFAEEDA),
                  isActive: stockFilter == 'Low stock',
                  onTap: () => onStockChipTap('Low stock'),
                ),
                const SizedBox(width: 6),
                _StockChip(
                  label: 'In stock',
                  count: inCount,
                  activeColor: const Color(0xFF3B6D11),
                  activeBg: const Color(0xFFE8F5E1),
                  isActive: stockFilter == 'In stock',
                  onTap: () => onStockChipTap('In stock'),
                ),
              ],
            ),
          ),

          // ── Table header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'PRODUCT & CATEGORIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888780),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  'PRICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888780),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ✅ FIX: Inline loader replaces the list while fetching —
          //         the search field above stays fully visible & focused
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C5CE7),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSearching
                          ? Icons.search_off_rounded
                          : Icons.inventory_2_outlined,
                      size: 32,
                      color: const Color(0xFFCCCCCC),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSearching
                          ? 'No products match your search'
                          : 'No products found',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888780),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 0.5,
                indent: 14,
                endIndent: 14,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (_, i) => _ProductRow(
                product: products[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsScreen(product: products[i]),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ── Pagination ──
          if (!isLoading && totalPages > 1) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            _PaginationRow(
              currentPage: currentPage,
              totalPages: totalPages,
              label: isSearching ? 'Search page' : 'Page',
              onPageChanged: onPageChanged,
              onPrev: onPrevPage,
              onNext: onNextPage,
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Pagination Row ───────────────────────────────────────────────────────────

class _PaginationRow extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String label;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginationRow({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onPrev,
    required this.onNext,
    this.label = 'Page',
  });

  List<_PageItem> _buildPageItems() {
    final items = <_PageItem>[];
    final Set<int> visible = {};

    visible.add(1);
    visible.add(totalPages);
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i >= 1 && i <= totalPages) visible.add(i);
    }

    final sorted = visible.toList()..sort();
    for (int idx = 0; idx < sorted.length; idx++) {
      if (idx > 0 && sorted[idx] - sorted[idx - 1] > 1) {
        items.add(_PageItem.ellipsis());
      }
      items.add(_PageItem.page(sorted[idx]));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final pageItems = _buildPageItems();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Text(
            '$label $currentPage of $totalPages',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
          ),
          const Spacer(),
          Row(
            children: [
              _PagButton(
                child: const Icon(Icons.chevron_left_rounded, size: 16),
                onTap: currentPage > 1 ? onPrev : null,
              ),
              const SizedBox(width: 4),
              ...pageItems.map((item) {
                if (item.isEllipsis) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '…',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888780)),
                    ),
                  );
                }
                final isActive = item.page == currentPage;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _PagButton(
                    isActive: isActive,
                    child: Text(
                      '${item.page}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF444441),
                      ),
                    ),
                    onTap: isActive ? null : () => onPageChanged(item.page!),
                  ),
                );
              }),
              _PagButton(
                child: const Icon(Icons.chevron_right_rounded, size: 16),
                onTap: currentPage < totalPages ? onNext : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageItem {
  final int? page;
  final bool isEllipsis;
  _PageItem.page(this.page) : isEllipsis = false;
  _PageItem.ellipsis() : page = null, isEllipsis = true;
}

class _PagButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isActive;

  const _PagButton({required this.child, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C5CE7) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(
            color: isActive
                ? Colors.white
                : (onTap == null
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xFF444441)),
            size: 16,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Filter Dropdown ──────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Color(0xFF888780),
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
          isDense: true,
          items: const [
            DropdownMenuItem(value: 'All stock', child: Text('All stock')),
            DropdownMenuItem(value: 'In stock', child: Text('In stock')),
            DropdownMenuItem(value: 'Low stock', child: Text('Low stock')),
            DropdownMenuItem(
              value: 'Out of stock',
              child: Text('Out of stock'),
            ),
          ],
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

// ─── Stock Chip ───────────────────────────────────────────────────────────────

class _StockChip extends StatelessWidget {
  final String label;
  final int count;
  final Color activeColor;
  final Color activeBg;
  final bool isActive;
  final VoidCallback onTap;

  const _StockChip({
    required this.label,
    required this.count,
    required this.activeColor,
    required this.activeBg,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: activeColor.withOpacity(0.3), width: 0.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF888780),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.15)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : const Color(0xFF888780),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Row ──────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final ProductResponseModel product;
  final void Function()? onTap;
  const _ProductRow({required this.product, required this.onTap});

  _StockStatus get _stockStatus {
    if (product.stock == 0) return _StockStatus.out;
    if (product.stock <= 10) return _StockStatus.low;
    return _StockStatus.ok;
  }

  @override
  Widget build(BuildContext context) {
    final status = _stockStatus;
    final imageUrl = product.imagesUrl != null && product.imagesUrl!.isNotEmpty
        ? product.imagesUrl!.first
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _ProductIconFallback(),
                      ),
                    )
                  : const _ProductIconFallback(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888780),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EGP ${product.price}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                _StockBadge(status: status, stock: product.stock),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductIconFallback extends StatelessWidget {
  const _ProductIconFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.inventory_2_outlined,
      size: 18,
      color: Color(0xFFB0B0B0),
    );
  }
}

// ─── Stock Badge ──────────────────────────────────────────────────────────────

enum _StockStatus { ok, low, out }

class _StockBadge extends StatelessWidget {
  final _StockStatus status;
  final int stock;
  const _StockBadge({required this.status, required this.stock});

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final Color? badgeBg;
    final Color? badgeText;
    final String? badgeLabel;

    switch (status) {
      case _StockStatus.ok:
        dotColor = const Color(0xFF3B6D11);
        badgeBg = null;
        badgeText = null;
        badgeLabel = null;
      case _StockStatus.low:
        dotColor = const Color(0xFFBA7517);
        badgeBg = const Color(0xFFFAEEDA);
        badgeText = const Color(0xFFBA7517);
        badgeLabel = 'Low';
      case _StockStatus.out:
        dotColor = const Color(0xFFA32D2D);
        badgeBg = const Color(0xFFFCEBEB);
        badgeText = const Color(0xFFA32D2D);
        badgeLabel = 'Out';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          'Stock: $stock',
          style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
        ),
        if (badgeLabel != null) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(fontSize: 9, color: badgeText),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Add Product Bottom Sheet ─────────────────────────────────────────────────

class _AddProductSheet extends StatefulWidget {
  final VoidCallback onProductAdded;
  const _AddProductSheet({required this.onProductAdded});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();

  static const _primary = Color(0xFF6C5CE7);
  static const _border = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddProductCubit>().createProduct(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: _priceController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      cost: _costController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<AddProductCubit, AddProductState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (_) {
            Navigator.of(context).pop();
            widget.onProductAdded();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully'),
                backgroundColor: Color(0xFF3B6D11),
              ),
            );
          },
          error: (errorHandler) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorHandler.apiErrorModel.error),
                backgroundColor: const Color(0xFFA32D2D),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add new product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Fill in the details to create a new product.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888780),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _border, width: 0.5),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF888780),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _FuseField(
                  controller: _nameController,
                  label: 'Product name',
                  hint: 'e.g. Wireless Headphones',
                  required: true,
                  autofocus: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _FuseField(
                        controller: _priceController,
                        label: 'Price (EGP)',
                        hint: '0',
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FuseField(
                        controller: _costController,
                        label: 'Cost (EGP)',
                        hint: '0.00',
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _FuseField(
                  controller: _stockController,
                  label: 'Stock quantity',
                  hint: '0',
                  required: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _FuseField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Short product description...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AddProductCubit, AddProductState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                              foregroundColor: const Color(0xFF1A1A1A),
                              side: const BorderSide(
                                color: _border,
                                width: 0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Add product'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Field ───────────────────────────────────────────────────────────

class _FuseField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  static const _primary = Color(0xFF6C5CE7);
  static const _border = Color(0xFFE0E0E0);

  const _FuseField({
    required this.controller,
    required this.label,
    required this.hint,
    this.required = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF444441),
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              const Text('*', style: TextStyle(fontSize: 12, color: _primary)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFB4B2A9)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFA32D2D),
                width: 0.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFA32D2D),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFA32D2D)),
          ),
        ),
      ],
    );
  }
}
