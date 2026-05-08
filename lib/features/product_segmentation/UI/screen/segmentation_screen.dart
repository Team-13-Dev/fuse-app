import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';
import 'package:fuse_system/features/product_segmentation/data/model/product_segmentation_response_model.dart';
import 'package:fuse_system/features/product_segmentation/logic/cubit/product_segmentation_cubit.dart';
import 'package:fuse_system/features/product_segmentation/logic/cubit/product_segmentation_state.dart';

class SegmentaionPage extends StatefulWidget {
  const SegmentaionPage({super.key});

  @override
  State<SegmentaionPage> createState() => _SegmentaionPageState();
}

class _SegmentaionPageState extends State<SegmentaionPage>
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
      backgroundColor: const Color(0xFFF5F6FA),
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

// ─── Custom AppBar wrapping FuseAppBar + TabBar ─────────────────────────────

class _SegmentationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TabController tabController;

  const _SegmentationAppBar({
    required this.scaffoldKey,
    required this.tabController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60 + 48 + 4);

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
        // ── Tab Bar ──
        Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorColor: const Color(0xFF5B4FE8),
              indicatorWeight: 2,
              labelColor: const Color(0xFF5B4FE8),
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
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SOON',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
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

// ─── Products Tab ───────────────────────────────────────────────────────────

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductSegmentationCubit, ProductSegmentationState>(
      builder: (context, state) {
        return state.when(
          initial: () => const _FirstRunPendingCard(),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF5B4FE8)),
          ),
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

// ─── First-run Pending ──────────────────────────────────────────────────────

class _FirstRunPendingCard extends StatelessWidget {
  final int? productCount;
  final int? minProductsNeeded;

  const _FirstRunPendingCard({this.productCount, this.minProductsNeeded});

  @override
  Widget build(BuildContext context) {
    final count = productCount;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: const Color(0xFFEEEEF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFF5B4FE8),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'First-run pending',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have enough products to segment ($count). '
              'Click "Refresh insights" above to run for the first time.',
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

// ─── Segments List ──────────────────────────────────────────────────────────

class _SegmentsListView extends StatelessWidget {
  final ProductSegmentationResponseModel data;
  const _SegmentsListView({required this.data});

  @override
  Widget build(BuildContext context) {
    final segments = data.segments ?? [];
    final clusters = data.clusters ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (data.lastJobAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Last updated: ${data.lastJobAt}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        if (segments.isEmpty && clusters.isEmpty)
          const _FirstRunPendingCard()
        else ...[
          if (segments.isNotEmpty) ...[
            const Text(
              'Segments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            ...segments.map((seg) => _SegmentCard(segment: seg)),
          ],
          if (clusters.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Clusters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            ...clusters.map((c) => _SegmentCard(segment: c)),
          ],
        ],
      ],
    );
  }
}

// ─── Segment Card ───────────────────────────────────────────────────────────

class _SegmentCard extends StatelessWidget {
  final dynamic segment;
  const _SegmentCard({required this.segment});

  @override
  Widget build(BuildContext context) {
    final name = segment['name']?.toString() ?? 'Segment';
    final count = segment['count']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bubble_chart_outlined,
              color: Color(0xFF5B4FE8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          if (count.isNotEmpty)
            Text(
              '$count items',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

// ─── Error Card ─────────────────────────────────────────────────────────────

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
          color: Colors.white,
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
                color: Color(0xFF1A1A2E),
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
                backgroundColor: const Color(0xFF5B4FE8),
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

// ─── Coming Soon Tab ────────────────────────────────────────────────────────

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
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Color(0xFFD97706),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
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
