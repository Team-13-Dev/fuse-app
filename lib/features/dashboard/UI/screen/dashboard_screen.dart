import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Routing/routes.dart';
import 'package:fuse_system/features/dashboard/data/model/dashboard_response_model.dart';
import 'package:fuse_system/features/dashboard/logic/cubit/dashboard_metrics_cubit.dart';
import 'package:fuse_system/features/dashboard/logic/cubit/dashboard_metrics_state.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';

// ─── Dashboard Screen ─────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerCtrl.forward();
    context.read<DashboardMetricsCubit>().fetchMetrics();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Animation<double> _staggered(double start, double end) {
    return CurvedAnimation(
      parent: _staggerCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 🌅';
    if (h < 17) return 'Good afternoon ☀️';
    return 'Good evening 👋';
  }

  void _navigateTo(String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEFF2F5),
      drawer: const FuseDrawer(activeItem: 'Dashboard'),
      appBar: const FuseAppBar(currentPage: "Dashboard"),
      body: SafeArea(
        child: BlocBuilder<DashboardMetricsCubit, DashboardMetricsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              success: (data) => _buildBody(data, isTablet, isDesktop),
              error: (errorHandler) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE17055),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorHandler.apiErrorModel.error,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DashboardMetricsCubit>().fetchMetrics(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(
    DashboardResponseModel data,
    bool isTablet,
    bool isDesktop,
  ) {
    final hPad = isDesktop
        ? 24.0
        : isTablet
        ? 20.0
        : 16.0;

    return SingleChildScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildGreeting(),
          const SizedBox(height: 16),
          _buildQuickActions(isTablet),
          const SizedBox(height: 20),
          _buildStatsGrid(data.metrics, isTablet, isDesktop),
          const SizedBox(height: 20),
          _buildRevenueChart(data.revenue, data.allTimeRevenue),
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRecentOrders(data.recent)),
                const SizedBox(width: 20),
                Expanded(child: _buildOrderMix(data.orderMix)),
              ],
            )
          else ...[
            _buildOrderMix(data.orderMix),
            const SizedBox(height: 20),
            _buildRecentOrders(data.recent),
          ],
          const SizedBox(height: 20),
          _buildShortcuts(isTablet),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    return FadeTransition(
      opacity: _staggered(0.0, 0.3),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_staggered(0.0, 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions(bool isTablet) {
    final actions = [
      {
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF5B4FE8),
        'label': 'Add Product',
        'route': Routes.productScreen,
      },
      {
        'icon': Icons.people_outline,
        'color': const Color(0xFF8B5CF6),
        'label': 'Add Customer',
        'route': Routes.customerScreen,
      },
      {
        'icon': Icons.label_outline,
        'color': const Color(0xFF3B82F6),
        'label': 'Add Category',
        'route': Routes.categoriesScreen,
      },
    ];

    return FadeTransition(
      opacity: _staggered(0.05, 0.35),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final color = a['color'] as Color;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < actions.length - 1 ? 10 : 0),
              child: _QuickActionButton(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
                color: color,
                onTap: () => _navigateTo(a['route'] as String),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Stats Grid from MetricModel list ─────────────────────────────────────

  Widget _buildStatsGrid(
    List<MetricModel> metrics,
    bool isTablet,
    bool isDesktop,
  ) {
    // Pull the revenue metric out separately for the large card.
    final revenueMetric = metrics.firstWhere(
      (m) => m.type == 'revenue',
      orElse: () => MetricModel(
        type: 'revenue',
        label: 'Revenue',
        value: '0',
        change: '0%',
        up: true,
        sub: '',
      ),
    );

    final otherMetrics = metrics.where((m) => m.type != 'revenue').toList();

    // Map type → icon / colour
    IconData _iconFor(String type) {
      switch (type) {
        case 'customers':
          return Icons.people_outline;
        case 'products':
          return Icons.inventory_2_outlined;
        case 'orders':
          return Icons.shopping_cart_outlined;
        default:
          return Icons.bar_chart_outlined;
      }
    }

    Color _colorFor(String type) {
      switch (type) {
        case 'customers':
          return const Color(0xFF5B4FE8);
        case 'products':
          return const Color(0xFF3B82F6);
        case 'orders':
          return const Color(0xFFE17055);
        default:
          return const Color(0xFF8B5CF6);
      }
    }

    String? _routeFor(String type) {
      switch (type) {
        case 'customers':
          return Routes.customerScreen;
        case 'products':
          return Routes.productScreen;
        case 'orders':
          return Routes.orderScreen;
        default:
          return null;
      }
    }

    // Dummy sparklines (kept as before; swap for real data if available)
    final List<double> _upSpark = [
      0.2,
      0.4,
      0.35,
      0.55,
      0.5,
      0.65,
      0.7,
      0.75,
      0.8,
      0.85,
    ];
    final List<double> _downSpark = [
      0.9,
      0.75,
      0.8,
      0.65,
      0.7,
      0.55,
      0.6,
      0.5,
      0.45,
      0.4,
    ];

    Widget revenueCard = _RevenueCard(
      metric: revenueMetric,
      sparkline: _upSpark,
    );

    List<Widget> statCards = otherMetrics.map((m) {
      final route = _routeFor(m.type);
      final sparkline = m.up ? _upSpark : _downSpark;
      final sparkColor = m.up
          ? const Color(0xFF00B894)
          : const Color(0xFFE17055);
      return _StatCard(
        icon: _iconFor(m.type),
        iconColor: _colorFor(m.type),
        value: m.value,
        change: m.change,
        subtitle: m.sub,
        label: m.label,
        positive: m.up,
        sparkline: sparkline,
        sparkColor: sparkColor,
        onTap: route != null ? () => _navigateTo(route) : null,
      );
    }).toList();

    return FadeTransition(
      opacity: _staggered(0.1, 0.5),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_staggered(0.1, 0.5)),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(flex: 2, child: revenueCard),
                  ...statCards.map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: card,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 55, child: revenueCard),
                      if (statCards.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(flex: 45, child: statCards.first),
                      ],
                    ],
                  ),
                  if (statCards.length > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: statCards
                          .skip(1)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: e.key > 0 ? 12 : 0,
                                ),
                                child: e.value,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  // ─── Revenue Chart from RevenueModel list ─────────────────────────────────

  Widget _buildRevenueChart(List<RevenueModel> revenue, int allTimeRevenue) {
    if (revenue.isEmpty) return const SizedBox.shrink();

    final maxVal = revenue.map((r) => r.value).reduce((a, b) => a > b ? a : b);
    final normalised = revenue
        .map((r) => maxVal > 0 ? r.value / maxVal : 0.0)
        .toList();
    final labels = revenue.map((r) => r.label).toList();

    return FadeTransition(
      opacity: _staggered(0.2, 0.6),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_staggered(0.2, 0.6)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Overview',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          'All-time · EGP ${_formatNumber(allTimeRevenue)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF00B894),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(height: 100, child: _BarChart(data: normalised)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map(
                      (l) => Flexible(
                        child: Text(
                          l,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Order Mix (replaces Live Activity) ───────────────────────────────────

  Widget _buildOrderMix(List<OrderMixModel> orderMix) {
    Color _colorForStatus(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
          return const Color(0xFF00B894);
        case 'pending':
          return const Color(0xFFFDAA3D);
        case 'failed':
        case 'cancelled':
          return const Color(0xFFE17055);
        default:
          return const Color(0xFF5B4FE8);
      }
    }

    IconData _iconForStatus(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
          return Icons.check_circle_outline;
        case 'pending':
          return Icons.schedule;
        case 'failed':
        case 'cancelled':
          return Icons.error_outline;
        default:
          return Icons.circle_outlined;
      }
    }

    return FadeTransition(
      opacity: _staggered(0.3, 0.65),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_staggered(0.3, 0.65)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Order Mix',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.donut_small_outlined,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...orderMix.asMap().entries.map((e) {
                final delay = e.key * 0.06;
                final item = e.value;
                final color = _colorForStatus(item.status);
                return FadeTransition(
                  opacity: _staggered(0.35 + delay, 0.7 + delay),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForStatus(item.status),
                            size: 16,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.status,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: item.pct / 100,
                                  backgroundColor: color.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.count}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              '${item.pct.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Recent Orders from RecentOrderModel list ─────────────────────────────

  Widget _buildRecentOrders(List<RecentOrderModel> orders) {
    return FadeTransition(
      opacity: _staggered(0.45, 0.8),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_staggered(0.45, 0.8)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _navigateTo(Routes.orderScreen),
                    child: const Row(
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5B4FE8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF5B4FE8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...orders.map((o) => _RecentOrderTile(order: o)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shortcuts ────────────────────────────────────────────────────────────

  Widget _buildShortcuts(bool isTablet) {
    final shortcuts = [
      {
        'icon': Icons.people_outline,
        'color': const Color(0xFF5B4FE8),
        'label': 'Customers',
        'sub': 'Manage your customer base',
        'route': Routes.customerScreen,
      },
      {
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF8B5CF6),
        'label': 'Products',
        'sub': 'Catalog, pricing & stock',
        'route': Routes.productScreen,
      },
      {
        'icon': Icons.label_outline,
        'color': const Color(0xFF7C3AED),
        'label': 'Categories',
        'sub': 'Organise your catalog',
        'route': Routes.categoriesScreen,
      },
    ];

    return FadeTransition(
      opacity: _staggered(0.65, 1.0),
      child: isTablet
          ? Row(
              children: shortcuts.map((s) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ShortcutCard(
                      icon: s['icon'] as IconData,
                      color: s['color'] as Color,
                      label: s['label'] as String,
                      subtitle: s['sub'] as String,
                      onTap: () => _navigateTo(s['route'] as String),
                    ),
                  ),
                );
              }).toList(),
            )
          : Column(
              children: shortcuts.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ShortcutCard(
                    icon: s['icon'] as IconData,
                    color: s['color'] as Color,
                    label: s['label'] as String,
                    subtitle: s['sub'] as String,
                    onTap: () => _navigateTo(s['route'] as String),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ─── Revenue Card (driven by MetricModel) ─────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final MetricModel metric;
  final List<double> sparkline;

  const _RevenueCard({required this.metric, required this.sparkline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4FE8).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    sparkline,
                    Colors.greenAccent,
                    false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'EGP',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            metric.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                metric.up ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: Colors.greenAccent,
              ),
              Text(
                ' ${metric.change}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.sub,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card (driven by MetricModel) ────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String change;
  final String subtitle;
  final String label;
  final bool positive;
  final List<double> sparkline;
  final Color sparkColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.change,
    required this.subtitle,
    required this.label,
    required this.positive,
    required this.sparkline,
    required this.sparkColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                SizedBox(
                  width: 60,
                  height: 32,
                  child: CustomPaint(
                    painter: _SparklinePainter(sparkline, sparkColor, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: positive
                      ? const Color(0xFF00B894)
                      : const Color(0xFFE17055),
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: positive
                        ? const Color(0xFF00B894)
                        : const Color(0xFFE17055),
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A6A),
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.open_in_new, size: 12, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Order Tile (driven by RecentOrderModel) ───────────────────────────

class _RecentOrderTile extends StatelessWidget {
  final RecentOrderModel order;
  const _RecentOrderTile({required this.order});

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00B894);
      case 'pending':
        return const Color(0xFFFDAA3D);
      case 'failed':
      case 'cancelled':
        return const Color(0xFFE17055);
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (order.status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule;
      case 'failed':
      case 'cancelled':
        return Icons.error_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
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
                ),
                const SizedBox(height: 2),
                Text(
                  order.orderNumber,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon, size: 11, color: _statusColor),
                const SizedBox(width: 4),
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'EGP ${order.total}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shortcut Card ────────────────────────────────────────────────────────────

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 17),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class _BarChart extends StatefulWidget {
  final List<double> data;
  const _BarChart({required this.data});

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _BarChartPainter(widget.data, _anim.value),
        size: Size.infinite,
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  _BarChartPainter(this.data, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final barW = size.width / (data.length * 1.6);
    final gap = size.width / data.length;
    // Highlight the last bar as the most recent period
    final activeIndex = data.length - 1;

    for (int i = 0; i < data.length; i++) {
      final h = data[i] * size.height * progress;
      final x = i * gap + (gap - barW) / 2;
      final y = size.height - h;
      final isActive = i == activeIndex;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [const Color(0xFF5B4FE8), const Color(0xFF7B6FF0)]
              : [const Color(0xFFE8EAED), const Color(0xFFF0F2F5)],
        ).createShader(Rect.fromLTWH(x, y, barW, h));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

// ─── Sparkline Painter ────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool filled;
  _SparklinePainter(this.data, this.color, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - data[i] * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => false;
}
