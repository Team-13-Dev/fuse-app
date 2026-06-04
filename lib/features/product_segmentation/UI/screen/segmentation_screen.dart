import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';
import 'package:fuse_system/features/product_segmentation/data/model/product_segmentation_response_model.dart';
import 'package:fuse_system/features/product_segmentation/logic/cubit/product_segmentation_cubit.dart';
import 'package:fuse_system/features/product_segmentation/logic/cubit/product_segmentation_state.dart';

// ─── Color constants ─────────────────────────────────────────────────────────

const _kPrimary = Color(0xFF5B4FE8);
const _kPrimaryLight = Color(0xFFEEEEF5);
const _kBlueGradientStart = Color(0xFF2979FF);
const _kBlueGradientEnd = Color(0xFF1565C0);
const _kBackground = Color(0xFFF5F6FA);
const _kCardBg = Colors.white;
const _kText = Color(0xFF1A1A2E);
const _kTextGrey = Color(0xFF8A8AA0);
const _kAmber = Color(0xFFD97706);
const _kAmberBg = Color(0xFFFEF3C7);

// ─── Page ────────────────────────────────────────────────────────────────────

class SegmentationPage extends StatefulWidget {
  const SegmentationPage({super.key});

  @override
  State<SegmentationPage> createState() => _SegmentationPageState();
}

class _SegmentationPageState extends State<SegmentationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProductSegmentationCubit>().getProductSegmentation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const FuseDrawer(activeItem: 'segmentation'),
      backgroundColor: _kBackground,
      appBar: _SegmentationAppBar(
        scaffoldKey: _scaffoldKey,
        tabController: _tabController,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_ProductsTab(), _ComingSoonTab()],
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _SegmentationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TabController tabController;

  const _SegmentationAppBar({
    required this.scaffoldKey,
    required this.tabController,
  });

  // FuseAppBar (~56) + header section (~150) + TabBar (~48)
  @override
  Size get preferredSize => const Size.fromHeight(56 + 150 + 48);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FuseAppBar(
          currentPage: 'Segmentation',
          onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
          notificationCount: 0,
        ),
        // ── Header with title + subtitle + refresh button ──
        Container(
          color: _kCardBg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Segmentation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'AI-driven groups discovered in your data, refreshed\nautomatically as it changes.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              _RefreshInsightsButton(),
            ],
          ),
        ),
        // ── Tab Bar ──
        Container(
          color: _kCardBg,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: _kPrimary,
              indicatorWeight: 2,
              labelColor: _kPrimary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    children: const [
                      Icon(Icons.inventory_2_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Products'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16),
                      const SizedBox(width: 6),
                      const Text('Customers'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _kAmberBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SOON',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _kAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Refresh Insights Button ──────────────────────────────────────────────────

class _RefreshInsightsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            context.read<ProductSegmentationCubit>().getProductSegmentation(),
        icon: const Icon(Icons.auto_awesome_outlined, size: 16),
        label: const Text('Refresh insights'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _kPrimary,
          side: const BorderSide(color: Color(0xFFDDE1F0)),
          backgroundColor: const Color(0xFFF0F1FF),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Products Tab ─────────────────────────────────────────────────────────────

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductSegmentationCubit, ProductSegmentationState>(
      builder: (context, state) {
        return state.when(
          initial: () => const _FirstRunPendingCard(),
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _kPrimary)),
          success: (data) {
            if (!(data.hasResults ?? false)) {
              return _FirstRunPendingCard(
                productCount: data.productCount,
                minProductsNeeded: data.minProductsNeeded,
              );
            }
            return _SegmentsListView(data: data);
          },
          error: (errorHandler) => _ErrorCard(
            message: errorHandler.toString(),
            onRetry: () => context
                .read<ProductSegmentationCubit>()
                .getProductSegmentation(),
          ),
        );
      },
    );
  }
}

// ─── First-run Pending ────────────────────────────────────────────────────────

class _FirstRunPendingCard extends StatelessWidget {
  final int? productCount;
  final int? minProductsNeeded;

  const _FirstRunPendingCard({this.productCount, this.minProductsNeeded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: _kPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'First-run pending',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productCount != null
                  ? 'You have enough products to segment ($productCount). '
                        'Click "Refresh insights" above to run for the first time.'
                  : 'Click "Refresh insights" above to run segmentation for the first time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segments List View ───────────────────────────────────────────────────────

class _SegmentsListView extends StatelessWidget {
  final ProductSegmentationResponseModel data;
  const _SegmentsListView({required this.data});

  @override
  Widget build(BuildContext context) {
    final clusters = data.clusters ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Stats Row: Clusters + Products + Last Updated ──
        _StatsRow(data: data),
        const SizedBox(height: 16),

        // ── Catalog Distribution ──
        if (clusters.isNotEmpty) ...[
          _CatalogDistributionCard(clusters: clusters),
          const SizedBox(height: 16),
        ],

        // ── Cluster Cards ──
        ...clusters.map((c) => _ClusterDetailCard(cluster: c)),

        // ── FAQ ──
        const SizedBox(height: 8),
        _HowAreClustersBuiltTile(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Stats Row (3 metric cards) ───────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ProductSegmentationResponseModel data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final clusterCount = data.clusters?.length ?? 0;
    final productCount = data.productCount ?? 0;
    final lastJob = data.lastJobAt ?? '';

    // Parse last job date for display
    String dateDisplay = '';
    String timeDisplay = '';
    try {
      final dt = DateTime.parse(lastJob);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateDisplay = '${months[dt.month - 1]} ${dt.day}';
      final h = dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
          ? 12
          : dt.hour;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final m = dt.minute.toString().padLeft(2, '0');
      timeDisplay = '$h:$m $amPm';
    } catch (_) {
      dateDisplay = lastJob;
    }

    return Column(
      children: [
        // ── Clusters card (blue gradient) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kBlueGradientStart, _kBlueGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bubble_chart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$clusterCount',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Clusters discovered',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Products + Last Updated (side by side) ──
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.inventory_2_outlined,
                iconColor: _kPrimary,
                iconBg: _kPrimaryLight,
                value: '$productCount',
                label: 'Products segmented of $productCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.trending_up_rounded,
                iconColor: _kPrimary,
                iconBg: _kPrimaryLight,
                value: dateDisplay,
                label: 'Last updated\n$timeDisplay',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Generic Metric Card ──────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Catalog Distribution Card ────────────────────────────────────────────────

class _CatalogDistributionCard extends StatelessWidget {
  final List<Cluster> clusters;
  const _CatalogDistributionCard({required this.clusters});

  @override
  Widget build(BuildContext context) {
    // Calculate total products
    final total = clusters.fold<int>(0, (sum, c) => sum + (c.numProducts ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Catalog distribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kText,
                ),
              ),
              Text(
                '$total products · ${clusters.length} clusters',
                style: const TextStyle(fontSize: 11, color: _kTextGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stacked progress bar ──
          _StackedBar(clusters: clusters, total: total),
          const SizedBox(height: 12),

          // ── Legend ──
          ...clusters.asMap().entries.map((entry) {
            final pct = total > 0
                ? ((entry.value.numProducts ?? 0) / total * 100).round()
                : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _clusterColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value.clusterName ?? 'Cluster ${entry.key + 1}',
                    style: const TextStyle(fontSize: 12, color: _kText),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Stacked Bar ──────────────────────────────────────────────────────────────

class _StackedBar extends StatelessWidget {
  final List<Cluster> clusters;
  final int total;
  const _StackedBar({required this.clusters, required this.total});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: clusters.asMap().entries.map((entry) {
                final pct = total > 0
                    ? (entry.value.numProducts ?? 0) / total
                    : 0.0;
                return Flexible(
                  flex: (pct * 1000).round(),
                  child: Container(color: _clusterColor(entry.key)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

Color _clusterColor(int index) {
  const colors = [
    Color(0xFF5B4FE8),
    Color(0xFF2979FF),
    Color(0xFF00BCD4),
    Color(0xFF43A047),
    Color(0xFFF4511E),
  ];
  return colors[index % colors.length];
}

// ─── Cluster Detail Card ──────────────────────────────────────────────────────

class _ClusterDetailCard extends StatefulWidget {
  final Cluster cluster;
  const _ClusterDetailCard({required this.cluster});

  @override
  State<_ClusterDetailCard> createState() => _ClusterDetailCardState();
}

class _ClusterDetailCardState extends State<_ClusterDetailCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.cluster;
    final name = c.clusterName ?? 'Cluster';
    final numProducts = c.numProducts ?? 0;

    // Catalog share %
    final catalogPct = c.revenueSharePct != null
        ? '${(c.revenueSharePct!).round()}%'
        : '--';
    final revPct = c.revenueSharePct != null
        ? '${c.revenueSharePct!.round()}%'
        : '--';
    final profPct = c.profitSharePct != null
        ? '${c.profitSharePct!.round()}%'
        : '--';

    final avgMargin = c.avgMargin != null
        ? '${c.avgMargin!.toStringAsFixed(1)}%'
        : '--';
    final revShare = c.revenueSharePct != null
        ? '${c.revenueSharePct!.toStringAsFixed(1)}%'
        : '--';
    final profShare = c.profitSharePct != null
        ? '${c.profitSharePct!.toStringAsFixed(1)}%'
        : '--';
    final avgPrice = c.avgPrice != null ? 'EGP ${c.avgPrice!.round()}' : '--';

    final isNegativeMargin = (c.avgMargin ?? 0) < 0;

    // Generate tags based on cluster characteristics
    final tags = _generateTags(c);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_outlined,
                    color: _kPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _kText,
                        ),
                      ),
                      Text(
                        '$numProducts products · ${_catalogShareLabel(c)}% of catalog',
                        style: const TextStyle(fontSize: 12, color: _kTextGrey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          if (_expanded) ...[
            // ── Tags ──
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: tags.map((tag) => _Tag(label: tag)).toList(),
                ),
              ),

            // ── Metrics Grid ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricItem(
                          icon: Icons.show_chart,
                          label: 'AVG MARGIN',
                          value: avgMargin,
                          valueColor: isNegativeMargin ? Colors.red : _kText,
                        ),
                      ),
                      Expanded(
                        child: _MetricItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'REVENUE SHARE',
                          value: revShare,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricItem(
                          icon: Icons.trending_up,
                          label: 'PROFIT SHARE',
                          value: profShare,
                        ),
                      ),
                      Expanded(
                        child: _MetricItem(
                          icon: Icons.sell_outlined,
                          label: 'AVG PRICE',
                          value: avgPrice,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Distribution Bars ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  _DistributionBar(
                    label: 'Catalog',
                    value: _catalogShareLabel(c) / 100,
                    displayValue:
                        '${_catalogShareLabel(c).toStringAsFixed(0)}%',
                    color: _kPrimary,
                  ),
                  const SizedBox(height: 8),
                  _DistributionBar(
                    label: 'Revenue',
                    value: (c.revenueSharePct ?? 0) / 100,
                    displayValue: '${(c.revenueSharePct ?? 0).round()}%',
                    color: _kPrimary,
                  ),
                  const SizedBox(height: 8),
                  _DistributionBar(
                    label: 'Profit',
                    value: (c.profitSharePct ?? 0) / 100,
                    displayValue: '${(c.profitSharePct ?? 0).round()}%',
                    color: _kPrimary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _catalogShareLabel(Cluster c) {
    // Use revenueSharePct as proxy for catalog share if not directly available
    return c.revenueSharePct ?? 0;
  }

  List<String> _generateTags(Cluster c) {
    final tags = <String>[];
    final margin = c.avgMargin ?? 0;
    final revShare = c.revenueSharePct ?? 0;
    final profShare = c.profitSharePct ?? 0;

    if (margin < 0) tags.add('Loss-making');
    if (margin > 0 && margin < 10) tags.add('Thin margin');
    if (margin >= 10) tags.add('High margin');
    if (revShare > 50) tags.add('Revenue driver');
    if (profShare > 50) tags.add('Profit driver');
    // "Fast moving" heuristic: high revenue/profit share
    if (revShare > 30 || profShare > 30) tags.add('Fast moving');

    return tags;
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final isNegative = label == 'Loss-making';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNegative ? const Color(0xFFFEE2E2) : const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNegative ? const Color(0xFFDC2626) : _kPrimary,
        ),
      ),
    );
  }
}

// ─── Metric Item ──────────────────────────────────────────────────────────────

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = _kText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: _kTextGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _kTextGrey,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Distribution Bar ─────────────────────────────────────────────────────────

class _DistributionBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final String displayValue;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFEEEEF5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            displayValue,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── How Are Clusters Built Tile ─────────────────────────────────────────────

class _HowAreClustersBuiltTile extends StatefulWidget {
  @override
  State<_HowAreClustersBuiltTile> createState() =>
      _HowAreClustersBuiltTileState();
}

class _HowAreClustersBuiltTileState extends State<_HowAreClustersBuiltTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    _open ? Icons.expand_more : Icons.chevron_right,
                    size: 18,
                    color: _kText,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'How are clusters built?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Clusters are built using an unsupervised machine learning algorithm (K-Means) '
                'that groups products based on their performance metrics such as margin, '
                'revenue share, price, and sales velocity. The algorithm automatically '
                'determines the optimal number of groups in your catalog.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coming Soon Tab ──────────────────────────────────────────────────────────

class _ComingSoonTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kAmberBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.people_outline, color: _kAmber, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _kText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer segmentation is on the way.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
