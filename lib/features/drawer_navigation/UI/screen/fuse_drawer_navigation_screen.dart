import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/DI/dependency_injection.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/core/Routing/routes.dart';
import 'package:fuse_system/features/ai_chat/UI/screen/ai_chat_screen.dart';
import 'package:fuse_system/features/ai_chat/UI/screen/chat_screen.dart';
import 'package:fuse_system/features/business_switch/data/model/business_switch_request_model.dart';
import 'package:fuse_system/features/business_switch/logic/cubit/business_switch_cubit.dart';
import 'package:fuse_system/features/business_switch/logic/cubit/business_switch_state.dart';
import 'package:fuse_system/features/drawer_navigation/UI/widgets/sign_out_bloc_listener.dart';
import 'package:fuse_system/features/drawer_navigation/logic/cubit/signout_cubit.dart';
import 'package:fuse_system/features/segment/data/model/segment_context_response_model.dart';
import 'package:fuse_system/features/segment/logic/cubit/segment_cubit.dart';
import 'package:fuse_system/features/segment/logic/cubit/segment_state.dart';

class FuseDrawer extends StatefulWidget {
  final String activeItem;
  const FuseDrawer({super.key, required this.activeItem});

  @override
  State<FuseDrawer> createState() => _FuseDrawerState();
}

class _FuseDrawerState extends State<FuseDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  bool _storeExpanded = false;
  bool _accountExpanded = false;

  final SignoutCubit _signoutCubit = getIt<SignoutCubit>();
  final SegmentCubit _segmentCubit = getIt<SegmentCubit>();
  final BusinessSwitchCubit _businessSwitchCubit = getIt<BusinessSwitchCubit>();

  // ── normalise once so every active comparison is case-insensitive ──
  String get _active => widget.activeItem.toLowerCase();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart);
    _ctrl.forward();

    // Only fetch segment if not already loaded
    final currentState = _segmentCubit.state;
    currentState.whenOrNull(
      initial: () => _segmentCubit.getSegment(),
      failure: (_) => _segmentCubit.getSegment(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF5B4FE8),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFE8543A),
    ];
    return colors[index % colors.length];
  }

  void _handleNavigation(BuildContext context, VoidCallback? onTap) {
    if (onTap == null) return;
    Navigator.of(context).pop();
    Future.delayed(const Duration(milliseconds: 100), onTap);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _signoutCubit),
        BlocProvider.value(value: _segmentCubit),
        BlocProvider.value(value: _businessSwitchCubit),
      ],
      child: SignOutBlocListener(
        // ── Business Switch listener ──────────────────────────────────────
        child: BlocListener<BusinessSwitchCubit, BusinessSwitchState>(
          bloc: _businessSwitchCubit,
          listener: (context, state) {
            state.when(
              initial: () {},
              // Show a subtle loading indicator while switching
              loading: () {},
              success: (data) {
                // data.businessId and data.role are already saved to secure
                // storage by the cubit — just refresh the segment and navigate.
                _segmentCubit.getSegment();
                setState(() => _storeExpanded = false);
                Navigator.of(context).pop(); // close drawer
                Future.delayed(
                  const Duration(milliseconds: 150),
                  () => context.pushNamedAndRemoveUntil(
                    Routes.dashboardScreen,
                    predicate: (r) => false,
                  ),
                );
              },
              error: (errorHandler) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorHandler.apiErrorModel.error),
                    backgroundColor: const Color(0xFFE8543A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            );
          },
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Drawer(
              width: MediaQuery.of(context).size.width * 0.85,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              backgroundColor: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildDrawerHeader(context), // ← stays fixed at top
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Segment-driven top section ──
                            BlocBuilder<SegmentCubit, SegmentState>(
                              bloc: _segmentCubit,
                              builder: (context, state) => state.when(
                                initial: () => const SizedBox.shrink(),
                                loading: () => const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: LinearProgressIndicator(
                                    color: Color(0xFF5B4FE8),
                                    backgroundColor: Color(0xFFEEEEF5),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                                success: (segment) => _buildTopSection(segment),
                                failure: (_) => const SizedBox.shrink(),
                              ),
                            ),

                            const Divider(
                              height: 24,
                              thickness: 1,
                              color: Color(0xFFEEEEF5),
                            ),

                            // ── Nav sections ──
                            _buildSection('OVERVIEW', [
                              _NavItem(
                                'Dashboard',
                                Icons.grid_view_rounded,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.dashboardScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'dashboard',
                              ),
                              _NavItem(
                                'Analytics',
                                Icons.bar_chart_rounded,
                                soon: true,
                                badge: '3',
                              ),
                            ]),
                            _buildSection('CATALOG', [
                              _NavItem(
                                'Products',
                                Icons.inventory_2_outlined,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.productScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'products',
                              ),
                              _NavItem(
                                'Categories',
                                Icons.label_outline,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.categoriesScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'categories',
                              ),
                              // ── ADD THIS ──
                              _NavItem(
                                'Segmentation',
                                Icons.auto_awesome_outlined,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.segmantsScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'segmentation',
                              ),
                            ]),
                            _buildSection('COMMERCE', [
                              _NavItem(
                                'Customers',
                                Icons.people_outline,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.customerScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'customers',
                              ),
                              _NavItem(
                                'Orders',
                                Icons.shopping_cart_outlined,
                                onTap: () => context.pushNamedAndRemoveUntil(
                                  Routes.orderScreen,
                                  predicate: (r) => false,
                                ),
                                active: _active == 'orders',
                                badge: '12',
                              ),
                              _NavItem(
                                'Coupons',
                                Icons.confirmation_number_outlined,
                                soon: true,
                              ),
                            ]),
                            _buildSection('GROWTH', [
                              _NavItem(
                                'Campaigns',
                                Icons.campaign_outlined,
                                soon: true,
                              ),
                              _NavItem(
                                'AI Insights',
                                Icons.auto_awesome_outlined,
                                soon: true,
                                isNew: true,
                              ),
                              _NavItem(
                                'Integrations',
                                Icons.bolt_outlined,
                                soon: true,
                              ),
                            ]),
                            _buildSection('PLATFORM', [
                              _NavItem(
                                'Fuse AI Assistant',
                                Icons.language_outlined,
                                isImage: true,
                                image: "assets/aiLogo.png",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AIChatScreen(),
                                  ),
                                ),
                                soon: false,
                              ),
                              _NavItem(
                                'Settings',
                                Icons.settings_outlined,
                                onTap: () {},
                                active: _active == 'settings',
                              ),
                            ]),

                            const SizedBox(height: 20),
                            _buildFooter(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Drawer Header ─────────────────────────────────────────────────────────

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Hero(
            tag: 'fuse_logo',
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B4FE8).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset("assets/Blue logo light.png"),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FUSE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Commerce Platform',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF888899),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF666680),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Section ──────────────────────────────────────────────────────────

  Widget _buildTopSection(SegmentContextResponseModel segment) {
    final activeBusiness = segment.businesses.firstWhere(
      (b) => b.id == segment.activeBusinessId,
      orElse: () => segment.businesses.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActiveStoreHeader(activeBusiness),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _storeExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'YOUR STORES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF888899),
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      // ── Show loading overlay while switching ──
                      BlocBuilder<BusinessSwitchCubit, BusinessSwitchState>(
                        bloc: _businessSwitchCubit,
                        builder: (context, switchState) {
                          final isSwitching = switchState.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          );
                          return Stack(
                            children: [
                              Column(
                                children: [
                                  ...segment.businesses.asMap().entries.map(
                                    (e) => _buildStoreItem(
                                      e.value,
                                      e.key,
                                      e.value.id == segment.activeBusinessId,
                                      isSwitching,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSwitching)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF5B4FE8),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildCreateNewStore(),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          _buildUserSection(segment),
        ],
      ),
    );
  }

  // ─── Active Store Header ───────────────────────────────────────────────────

  Widget _buildActiveStoreHeader(BusinessModel business) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _storeExpanded = !_storeExpanded),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _storeAvatar(business.name, 0, size: 38, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            business.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _roleBadge(business.role),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _iconRow(
                      Icons.storefront_outlined,
                      '/${business.tenantSlug}',
                    ),
                    const SizedBox(height: 2),
                    _iconRow(Icons.category_outlined, business.industry),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _storeExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: _storeExpanded
                      ? const Color(0xFF5B4FE8)
                      : const Color(0xFF888899),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Store List Item ───────────────────────────────────────────────────────

  Widget _buildStoreItem(
    BusinessModel business,
    int index,
    bool isActive,
    bool isSwitching,
  ) {
    return InkWell(
      // Disable tapping while a switch is in progress or if already active
      onTap: (isActive || isSwitching)
          ? null
          : () => _businessSwitchCubit.businessSwitch(
              BusinessSwitchRequestModel(businessId: business.id),
            ),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0EFFE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF5B4FE8).withOpacity(0.3)
                : const Color(0xFFEEEEF5),
          ),
        ),
        child: Row(
          children: [
            _storeAvatar(
              business.name,
              index,
              size: 34,
              radius: 8,
              fontSize: 11,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          business.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _roleBadge(business.role),
                    ],
                  ),
                  Text(
                    '/${business.tenantSlug}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888899),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: Color(0xFF5B4FE8),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.grey[350],
              ),
          ],
        ),
      ),
    );
  }

  // ─── Create New Store ──────────────────────────────────────────────────────

  Widget _buildCreateNewStore() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF5B4FE8).withOpacity(0.35),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_rounded, size: 18, color: Color(0xFF5B4FE8)),
              SizedBox(width: 8),
              Text(
                'Create new store',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B4FE8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── User Account Section ──────────────────────────────────────────────────

  Widget _buildUserSection(SegmentContextResponseModel segment) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _accountExpanded = !_accountExpanded),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accountExpanded
                    ? const Color(0xFFF4F5F7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4FE8).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials(segment.user.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                segment.user.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _roleBadge(segment.role),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          segment.user.email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888899),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _accountExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: _accountExpanded
                          ? const Color(0xFF5B4FE8)
                          : const Color(0xFF888899),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _accountExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildAccountMenuItem(
                      icon: Icons.person_outline,
                      label: 'Profile Settings',
                      onTap: () {},
                    ),
                    _buildAccountMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      badge: '5',
                      onTap: () {},
                    ),
                    _buildAccountMenuItem(
                      icon: Icons.security_outlined,
                      label: 'Security',
                      onTap: () {},
                    ),
                    _buildAccountMenuItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildAccountMenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      onTap: () => _signoutCubit.signOut(),
                      isDestructive: true,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ─── Account Menu Item ─────────────────────────────────────────────────────

  Widget _buildAccountMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDestructive ? onTap : () => _handleNavigation(context, onTap),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? const Color(0xFFE8543A)
                    : const Color(0xFF666680),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? const Color(0xFFE8543A)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B4FE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Colors.grey[350],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Nav Section Builder ───────────────────────────────────────────────────

  Widget _buildSection(String title, List<_NavItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey[400],
              letterSpacing: 1.3,
            ),
          ),
        ),
        ...items.asMap().entries.map(
          (e) => _AnimatedNavTile(
            item: e.value,
            delayFraction: e.key * 0.04,
            controller: _ctrl,
            onNavigate: _handleNavigation,
          ),
        ),
      ],
    );
  }

  // ─── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B4FE8).withOpacity(0.08),
            const Color(0xFF7B6FF0).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5B4FE8).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  size: 18,
                  color: Color(0xFF5B4FE8),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock advanced features and boost your business',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4FE8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared small widgets ──────────────────────────────────────────────────

  Widget _storeAvatar(
    String name,
    int index, {
    required double size,
    required double radius,
    double fontSize = 13,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _avatarColor(index),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B4FE8).withOpacity(0.15),
            const Color(0xFF7B6FF0).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${role[0].toUpperCase()}${role.substring(1)}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5B4FE8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 11, color: const Color(0xFF888899)),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888899)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final String? image;
  final bool isImage;
  final IconData icon;
  final bool active;
  final bool soon;
  final bool isNew;
  final String? badge;
  final void Function()? onTap;

  _NavItem(
    this.label,
    this.icon, {
    this.active = false,
    this.soon = false,
    this.isNew = false,
    this.badge,
    this.onTap,
    this.isImage = false,
    this.image,
  });
}

// ─── Animated Nav Tile ────────────────────────────────────────────────────────

class _AnimatedNavTile extends StatefulWidget {
  final _NavItem item;
  final double delayFraction;
  final AnimationController controller;
  final Function(BuildContext, VoidCallback?) onNavigate;

  const _AnimatedNavTile({
    required this.item,
    required this.delayFraction,
    required this.controller,
    required this.onNavigate,
  });

  @override
  State<_AnimatedNavTile> createState() => _AnimatedNavTileState();
}

class _AnimatedNavTileState extends State<_AnimatedNavTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(
        (0.2 + widget.delayFraction).clamp(0.0, 0.95),
        (0.6 + widget.delayFraction).clamp(0.05, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.2, 0),
          end: Offset.zero,
        ).animate(anim),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTapDown: widget.item.soon
                ? null
                : (_) => setState(() => _pressed = true),
            onTapUp: widget.item.soon
                ? null
                : (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.item.soon
                ? null
                : () => widget.onNavigate(context, widget.item.onTap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.item.active
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF5B4FE8).withOpacity(0.1),
                          const Color(0xFF7B6FF0).withOpacity(0.1),
                        ],
                      )
                    : null,
                color: widget.item.active
                    ? null
                    : _pressed
                    ? const Color(0xFFF0F0F5)
                    : _hovered
                    ? const Color(0xFFF8F8FA)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: widget.item.active
                    ? Border.all(
                        color: const Color(0xFF5B4FE8).withOpacity(0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.item.active
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.item.isImage
                        ? SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              widget.item.image!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            widget.item.icon,
                            size: 20,
                            color: widget.item.active
                                ? const Color(0xFF5B4FE8)
                                : widget.item.soon
                                ? Colors.grey[350]
                                : const Color(0xFF4A4A6A),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.item.active
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: widget.item.active
                            ? const Color(0xFF5B4FE8)
                            : widget.item.soon
                            ? Colors.grey[350]
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  if (widget.item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4FE8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.item.badge!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (widget.item.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (widget.item.soon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SOON',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (widget.item.active)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
