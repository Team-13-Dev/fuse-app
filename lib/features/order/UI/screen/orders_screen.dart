import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';
import 'package:fuse_system/features/order/UI/screen/order_details_screen.dart';
import 'package:fuse_system/features/order/UI/widgets/add_order_bottom_sheet.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';
import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';
import 'package:fuse_system/features/order/logic/cubit/order_state.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _primary = Color(0xFF5046E5);
  static const _tabs = [
    'All',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  List<OrderResponseModel> _displayedOrders = [];
  bool _isLoadingOrders = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<OrderCubit>().fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Opens the Add Order bottom sheet.
  ///
  /// The sheet calls Navigator.pop(true) on success.
  /// We then show the snackbar HERE — from OrdersScreen's Scaffold context,
  /// which is still fully alive after the sheet dismisses.
  /// This is the correct pattern: never show snackbars from a context that
  /// is about to be (or has just been) popped.
  Future<void> _openAddOrder() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.black54,
      useSafeArea: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<OrderCubit>()),
          BlocProvider.value(value: context.read<CustomerCubit>()),
          BlocProvider.value(value: context.read<ProductCubit>()),
        ],
        child: const AddOrderBottomSheet(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // ✅ Refresh list
      context.read<OrderCubit>().fetchOrders();

      // ✅ Show snackbar from OrdersScreen's Scaffold — sheet is already gone
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Order created successfully!',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF5046E5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    final cubit = context.read<OrderCubit>();
    if (value.trim().isEmpty) {
      setState(() => _isSearching = false);
      cubit.fetchOrders();
    } else {
      setState(() => _isSearching = true);
      cubit.searchOrders(value);
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _isSearching = false);
    context.read<OrderCubit>().fetchOrders();
  }

  List<OrderResponseModel> _filtered(List<OrderResponseModel> all) {
    final tab = _tabs[_tabController.index];
    return all.where((o) {
      return tab == 'All' || o.status.toLowerCase() == tab.toLowerCase();
    }).toList();
  }

  int _countByStatus(List<OrderResponseModel> all, String status) =>
      all.where((o) => o.status.toLowerCase() == status.toLowerCase()).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: FuseAppBar(currentPage: "Orders"),
      drawer: const FuseDrawer(activeItem: 'Orders'),
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () => setState(() => _isLoadingOrders = true),
              success: (orders) => setState(() {
                _displayedOrders = orders;
                _isLoadingOrders = false;
              }),
              successCreate: (_) {},
              successDelete: () {
                setState(() => _isLoadingOrders = false);
                context.read<OrderCubit>().fetchOrders();
              },
              error: (_) => setState(() => _isLoadingOrders = false),
            );
          },
          builder: (context, state) {
            if (_isLoadingOrders && _displayedOrders.isEmpty && !_isSearching) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primary,
                  strokeWidth: 2,
                ),
              );
            }

            return state.maybeWhen(
              error: (errorHandler) => !_isSearching
                  ? _ErrorView(
                      message: errorHandler.apiErrorModel.error,
                      onRetry: () => context.read<OrderCubit>().fetchOrders(),
                    )
                  : _buildBody(),
              orElse: () => _buildBody(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    final cubit = context.read<OrderCubit>();
    final pending = _countByStatus(_displayedOrders, 'pending');
    final confirmed = _countByStatus(_displayedOrders, 'confirmed');
    final filtered = _filtered(_displayedOrders);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: _primary,
            onRefresh: () async => context.read<OrderCubit>().fetchOrders(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Hero ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Orders',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Track and manage customer orders.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openAddOrder,
                        icon: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'New order',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats Row ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'TOTAL ORDERS',
                          value: '${_displayedOrders.length}',
                          icon: Icons.shopping_bag_outlined,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'CONFIRMED',
                          value: '$confirmed',
                          sub: 'Ready to ship',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'PENDING',
                          value: '$pending',
                          sub: 'Needs action',
                          icon: Icons.access_time_rounded,
                          isWarning: pending > 0,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── All Orders Card ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Card Header ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Row(
                            children: [
                              Text(
                                _isSearching
                                    ? 'Search results (${filtered.length})'
                                    : 'All orders',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EFFE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_displayedOrders.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_isSearching)
                                GestureDetector(
                                  onTap: _clearSearch,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE5E5E5),
                                      ),
                                    ),
                                    child: Text(
                                      'Clear search',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () =>
                                      context.read<OrderCubit>().fetchOrders(),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE5E5E5),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ── Search Bar ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isSearching
                                    ? _primary.withOpacity(0.5)
                                    : const Color(0xFFE5E5E5),
                                width: _isSearching ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1A2E),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by order ID or customer…',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  size: 17,
                                  color: _isSearching
                                      ? _primary
                                      : Colors.grey.shade400,
                                ),
                                suffixIcon: _isSearching
                                    ? GestureDetector(
                                        onTap: _clearSearch,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),

                        // ── Search Hint Banner ──
                        if (_isSearching)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Results update automatically as you type',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 10),

                        // ── Status Tabs ──
                        SizedBox(
                          height: 32,
                          child: TabBar(
                            controller: _tabController,
                            onTap: (_) => setState(() {}),
                            isScrollable: true,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            tabAlignment: TabAlignment.start,
                            indicator: const BoxDecoration(),
                            dividerColor: Colors.transparent,
                            labelPadding: const EdgeInsets.only(right: 6),
                            tabs: _tabs.map((s) {
                              final count = s == 'All'
                                  ? _displayedOrders.length
                                  : _countByStatus(_displayedOrders, s);
                              final isSelected =
                                  _tabs[_tabController.index] == s;
                              return _StatusTab(
                                label: s,
                                count: count,
                                isSelected: isSelected,
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Divider(height: 1, color: Colors.grey.shade100),

                        // ── Order List / Loader / Empty ──
                        if (_isLoadingOrders)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          _EmptyState(hasSearch: _isSearching)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, i) => _OrderRow(
                              order: filtered[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<OrderCubit>(),
                                    child: OrderDetailScreen(
                                      order: filtered[i],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // ── Pagination ──
                        if (!_isLoadingOrders && cubit.totalPages > 1) ...[
                          Divider(height: 1, color: Colors.grey.shade100),
                          _PaginationRow(
                            currentPage: cubit.currentPage,
                            totalPages: cubit.totalPages,
                            label: _isSearching ? 'Search page' : 'Page',
                            onPageChanged: (page) => cubit.gotoPage(page),
                            onPrev: () => cubit.gotoPage(cubit.currentPage - 1),
                            onNext: () => cubit.gotoPage(cubit.currentPage + 1),
                          ),
                        ],

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error View ─────────────────────────────────────────────────────────────

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
            color: Color(0xFF991B1B),
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
              backgroundColor: const Color(0xFF5046E5),
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

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 26,
              color: Color(0xFF5046E5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasSearch ? 'No results found' : 'No orders yet',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearch
                ? 'Try a different search term or clear the filter.'
                : 'Orders will appear here once customers place them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final bool isPrimary;
  final bool isWarning;

  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    this.isPrimary = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5046E5);
    final bg = isPrimary
        ? primary
        : isWarning
        ? const Color(0xFFFFF7ED)
        : Colors.white;
    final textColor = isPrimary
        ? Colors.white
        : isWarning
        ? const Color(0xFFC2410C)
        : const Color(0xFF1A1A2E);
    final subColor = isPrimary
        ? Colors.white60
        : isWarning
        ? const Color(0xFFEA580C).withOpacity(0.7)
        : Colors.grey.shade400;
    final iconBg = isPrimary
        ? Colors.white.withOpacity(0.15)
        : isWarning
        ? const Color(0xFFFFEDD5)
        : const Color(0xFFF5F5F7);
    final iconColor = isPrimary
        ? Colors.white
        : isWarning
        ? const Color(0xFFEA580C)
        : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary || isWarning
            ? null
            : Border.all(color: const Color(0xFFEEEEEE)),
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
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: subColor,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          if (sub != null)
            Text(
              sub!,
              style: TextStyle(fontSize: 9.5, color: subColor, height: 1.3),
            ),
        ],
      ),
    );
  }
}

// ── Status Tab ─────────────────────────────────────────────────────────────

class _StatusTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  const _StatusTab({
    required this.label,
    required this.count,
    required this.isSelected,
  });

  Color _color() {
    switch (label.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF15803D);
      case 'shipped':
        return const Color(0xFF1D4ED8);
      case 'delivered':
        return const Color(0xFF6D28D9);
      case 'cancelled':
        return const Color(0xFF991B1B);
      case 'all':
        return const Color(0xFF5046E5);
      default:
        return const Color(0xFFE55B0A);
    }
  }

  Color _bg() {
    switch (label.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFDCFCE7);
      case 'shipped':
        return const Color(0xFFDBEAFE);
      case 'delivered':
        return const Color(0xFFEDE9FE);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      case 'all':
        return const Color(0xFFEDE9FE);
      default:
        return const Color(0xFFFEF0E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 28,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? _color() : _bg(),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _color(),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : _color().withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : _color(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Row ──────────────────────────────────────────────────────────────

class _OrderRow extends StatelessWidget {
  final OrderResponseModel order;
  final VoidCallback onTap;
  const _OrderRow({required this.order, required this.onTap});

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();
  }

  Color _statusColor() {
    switch (order.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF15803D);
      case 'shipped':
        return const Color(0xFF1D4ED8);
      case 'delivered':
        return const Color(0xFF6D28D9);
      case 'cancelled':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFFE55B0A);
    }
  }

  Color _statusBg() {
    switch (order.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFDCFCE7);
      case 'shipped':
        return const Color(0xFFDBEAFE);
      case 'delivered':
        return const Color(0xFFEDE9FE);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF0E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE0E7FF),
              child: Text(
                _initials(order.customerName),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5046E5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${order.id.length > 12 ? order.id.substring(0, 12) : order.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status[0].toUpperCase() + order.status.substring(1),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${order.total}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pagination Row ─────────────────────────────────────────────────────────

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
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '…',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }
                final isActive = item.page == currentPage;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _PagButton(
                    isActive: isActive,
                    onTap: isActive ? null : () => onPageChanged(item.page!),
                    child: Text(
                      '${item.page}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF444441),
                      ),
                    ),
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
          color: isActive ? const Color(0xFF5046E5) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF5046E5) : const Color(0xFFE5E5E5),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(
            color: isActive
                ? Colors.white
                : onTap == null
                ? const Color(0xFFCCCCCC)
                : const Color(0xFF444441),
            size: 16,
          ),
          child: child,
        ),
      ),
    );
  }
}
