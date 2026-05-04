import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/categories/UI/widgets/add_categories_bloc_listener.dart';
import 'package:fuse_system/features/categories/data/model/add_categories_request_model.dart';
import 'package:fuse_system/features/categories/data/model/categories_response_model.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_cubit.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_state.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, bool> _expandedMap = {};

  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Stats helpers ──────────────────────────────────────────────────────────

  int _totalCount(List<CategoriesResponseModel> categories) {
    int count = 0;
    for (var cat in categories) {
      count++;
      count += cat.children.length;
    }
    return count;
  }

  int _rootCount(List<CategoriesResponseModel> categories) => categories.length;

  int _subCatCount(List<CategoriesResponseModel> categories) {
    int count = 0;
    for (var cat in categories) {
      count += cat.children.length;
    }
    return count;
  }

  bool _isExpanded(String id) => _expandedMap[id] ?? false;

  void _toggleExpanded(String id) =>
      setState(() => _expandedMap[id] = !(_expandedMap[id] ?? false));

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AddCategoriesBlocListener(
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        buildWhen: (prev, curr) => curr.maybeWhen(
          loading: () => true,
          success: (_) => true,
          error: (_) => true,
          orElse: () => false,
        ),
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: const FuseDrawer(activeItem: 'Categories'),
            appBar: FuseAppBar(currentPage: "Categories"),
            backgroundColor: const Color(0xFFF4F5F7),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: state.maybeWhen(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5B4FE8),
                        ),
                      ),
                      orElse: () {
                        final categories = state.maybeWhen(
                          success: (data) => data,
                          orElse: () => <CategoriesResponseModel>[],
                        );
                        return _buildBody(categories);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(List<CategoriesResponseModel> categories) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeTransition(
        opacity: _headerFadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAddButton(categories),
            const SizedBox(height: 20),
            _buildStatsRow(categories),
            const SizedBox(height: 20),
            _buildCategoryTree(categories),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organise your product catalog with a hierarchical\ncategory tree (up to 3 levels deep).',
          style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
        ),
      ],
    );
  }

  // ─── Add Button ─────────────────────────────────────────────────────────────

  Widget _buildAddButton(List<CategoriesResponseModel> categories) {
    return _AnimatedButton(
      onTap: () => _showAddDialog(categories),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B4FE8).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow(List<CategoriesResponseModel> categories) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'TOTAL',
            value: '${_totalCount(categories)}',
            subtitle: 'All categories',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'ROOT',
            value: '${_rootCount(categories)}',
            subtitle: 'Top-level',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'SUB-CATS',
            value: '${_subCatCount(categories)}',
            subtitle: 'Nested',
          ),
        ),
      ],
    );
  }

  // ─── Category Tree ───────────────────────────────────────────────────────────

  Widget _buildCategoryTree(List<CategoriesResponseModel> categories) {
    final filtered = _searchQuery.isEmpty
        ? categories
        : categories
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    c.children.any(
                      (ch) => ch.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  'Category tree (${_totalCount(categories)})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Expanded(child: _buildSearchField()),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No categories found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cat = filtered[index];
                return _CategoryTile(
                  category: cat,
                  isExpanded: _isExpanded(cat.id),
                  onToggle: () => _toggleExpanded(cat.id),
                  onAddChild: () => _showAddChildDialog(cat),
                  onDeleteChild: (_) {
                    // TODO: wire delete API when available
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search... (/)',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  void _showAddDialog(List<CategoriesResponseModel> categories) {
    _openDialog(
      _AddCategoryDialog(
        categories: categories,
        onAdd: (name, parentId, description, imageUrl) {
          context.read<CategoriesCubit>().createCategory(
            AddCategoriesRequestModel(
              name: name,
              parentId: parentId,
              description: description.isEmpty ? null : description,
              imageUrl: imageUrl.isEmpty ? null : imageUrl,
            ),
          );
        },
      ),
    );
  }

  void _showAddChildDialog(CategoriesResponseModel parent) {
    _openDialog(
      _AddCategoryDialog(
        categories: const [],
        preselectedParentId: parent.id,
        preselectedParentName: parent.name,
        onAdd: (name, parentId, description, imageUrl) {
          context.read<CategoriesCubit>().createCategory(
            AddCategoriesRequestModel(
              name: name,
              parentId: parentId,
              description: description.isEmpty ? null : description,
              imageUrl: imageUrl.isEmpty ? null : imageUrl,
            ),
          );
        },
      ),
    );
  }

  /// Shared dialog launcher with smooth fade + scale entrance.
  void _openDialog(Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => BlocProvider.value(
        value: context.read<CategoriesCubit>(),
        child: child,
      ),
      transitionBuilder: (_, anim, __, dialogChild) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: dialogChild,
          ),
        );
      },
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatefulWidget {
  final CategoriesResponseModel category;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddChild;
  final Function(CategoriesResponseModel) onDeleteChild;

  const _CategoryTile({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddChild,
    required this.onDeleteChild,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(_CategoryTile old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded
          ? _expandController.forward()
          : _expandController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _hovering
                ? const Color(0xFF5B4FE8).withOpacity(0.04)
                : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.category.children.isNotEmpty)
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedRotation(
                        turns: widget.isExpanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF5B4FE8),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B4FE8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: Color(0xFF5B4FE8),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.category.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              trailing: _hovering
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _IconBtn(
                          icon: Icons.add,
                          color: const Color(0xFF5B4FE8),
                          onTap: widget.onAddChild,
                        ),
                      ],
                    )
                  : null,
              onTap: widget.category.children.isNotEmpty
                  ? widget.onToggle
                  : null,
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          axisAlignment: -1,
          child: Column(
            children: widget.category.children.map((child) {
              return _ChildTile(
                child: child,
                onDelete: () => widget.onDeleteChild(child),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Child Tile ───────────────────────────────────────────────────────────────

class _ChildTile extends StatefulWidget {
  final CategoriesResponseModel child;
  final VoidCallback onDelete;

  const _ChildTile({required this.child, required this.onDelete});

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovering
            ? const Color(0xFF5B4FE8).withOpacity(0.03)
            : Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.only(
            left: 56,
            right: 16,
            top: 0,
            bottom: 0,
          ),
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.folder_outlined,
              size: 14,
              color: Colors.grey,
            ),
          ),
          title: Text(
            widget.child.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A6A),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
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
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ─── Add Category Dialog ──────────────────────────────────────────────────────

class _AddCategoryDialog extends StatefulWidget {
  final List<CategoriesResponseModel> categories;
  final String? preselectedParentId;
  final String? preselectedParentName;
  final Function(
    String name,
    String? parentId,
    String description,
    String imageUrl,
  )
  onAdd;

  const _AddCategoryDialog({
    required this.categories,
    required this.onAdd,
    this.preselectedParentId,
    this.preselectedParentName,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _descFocus = FocusNode();
  final _urlFocus = FocusNode();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();

  late String? _selectedParentId;
  bool _isSubmitting = false;
  bool _showOptional = false;

  // Per-field stagger
  late AnimationController _staggerCtrl;
  late List<Animation<double>> _fieldAnims;

  @override
  void initState() {
    super.initState();
    _selectedParentId = widget.preselectedParentId;

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // 4 slots: name, parent/locked-parent, optional-toggle, optional-body
    _fieldAnims = List.generate(4, (i) {
      final start = (i * 0.14).clamp(0.0, 1.0);
      final end = (start + 0.55).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _staggerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _nameController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    widget.onAdd(
      _nameController.text.trim(),
      _selectedParentId,
      _descController.text.trim(),
      _imageController.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  void _dismiss() => Navigator.pop(context);

  Widget _staggered(int index, Widget child) {
    return AnimatedBuilder(
      animation: _fieldAnims[index],
      builder: (_, __) => Opacity(
        opacity: _fieldAnims[index].value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - _fieldAnims[index].value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLockedParent = widget.preselectedParentId != null;

    // Responsive width
    final dialogWidth = mq.size.width < 480
        ? mq.size.width - 32
        : (mq.size.width < 720 ? mq.size.width * 0.86 : 500.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: mq.size.width < 480 ? 16 : 20,
        vertical: mq.viewInsets.bottom > 0 ? 16 : 40,
      ),
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogHeader(isLockedParent),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      mq.viewInsets.bottom > 0 ? 12 : 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name ──
                        _staggered(0, _buildNameField()),
                        const SizedBox(height: 16),

                        // ── Parent / Locked parent ──
                        _staggered(
                          1,
                          isLockedParent
                              ? _buildLockedParentTile()
                              : _buildParentDropdown(),
                        ),
                        const SizedBox(height: 16),

                        // ── Optional toggle ──
                        _staggered(2, _buildOptionalToggle()),

                        // ── Optional fields (desc + image) ──
                        _staggered(
                          3,
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: _showOptional
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildDescriptionField(),
                                      const SizedBox(height: 16),
                                      _buildImageUrlField(),
                                      const SizedBox(height: 4),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildDialogFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildDialogHeader(bool isChild) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FE8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isChild ? Icons.account_tree_outlined : Icons.add_box_outlined,
              color: const Color(0xFF5B4FE8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChild
                      ? 'Add child to "${widget.preselectedParentName}"'
                      : 'Add new category',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Categories organise your product catalog.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFF666680),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Name field ───────────────────────────────────────────────────────────────

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Name', required: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          autofocus: true,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _descFocus.requestFocus(),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: 'e.g. Accessories',
            prefixIcon: Icons.label_outline_rounded,
          ),
        ),
      ],
    );
  }

  // ── Parent dropdown ───────────────────────────────────────────────────────────

  Widget _buildParentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Parent category'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          value: _selectedParentId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF666680),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: _inputDecoration(
            hint: '',
            prefixIcon: Icons.account_tree_outlined,
          ),
          onChanged: (val) => setState(() => _selectedParentId = val),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'None (root category)',
                style: TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              ),
            ),
            ...widget.categories.map(
              (cat) => DropdownMenuItem<String?>(
                value: cat.id,
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Optional — leave empty to make this a top-level category.',
          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
        ),
      ],
    );
  }

  // ── Locked parent tile ───────────────────────────────────────────────────────

  Widget _buildLockedParentTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4FE8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF5B4FE8).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_tree_outlined,
            size: 16,
            color: Color(0xFF5B4FE8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent category',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF5B4FE8).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.preselectedParentName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FE8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Fixed',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF5B4FE8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Optional toggle ───────────────────────────────────────────────────────────

  Widget _buildOptionalToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showOptional = !_showOptional),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.grey.withOpacity(0.25), thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Optional fields',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B4FE8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _showOptional ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: Color(0xFF5B4FE8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(color: Colors.grey.withOpacity(0.25), thickness: 1),
          ),
        ],
      ),
    );
  }

  // ── Description field ─────────────────────────────────────────────────────────

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Description'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _descController,
          focusNode: _descFocus,
          maxLines: 3,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _urlFocus.requestFocus(),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: _inputDecoration(
            hint: 'Short description...',
            prefixIcon: Icons.notes_rounded,
          ),
        ),
      ],
    );
  }

  // ── Image URL field ───────────────────────────────────────────────────────────

  Widget _buildImageUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Image URL'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _imageController,
          focusNode: _urlFocus,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final uri = Uri.tryParse(v.trim());
            if (uri == null || !uri.hasAbsolutePath || !uri.hasScheme) {
              return 'Enter a valid URL';
            }
            return null;
          },
          decoration: _inputDecoration(
            hint: 'https://...',
            prefixIcon: Icons.image_outlined,
          ),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  Widget _buildDialogFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : _dismiss,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666680),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          _AnimatedButton(
            onTap: _isSubmitting ? () {} : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: _isSubmitting
                    ? const LinearGradient(
                        colors: [Color(0xFFAAAAAA), Color(0xFFCCCCCC)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
                      ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: _isSubmitting
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF5B4FE8).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSubmitting
                    ? const SizedBox(
                        key: ValueKey('loader'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add category',
                        key: ValueKey('label'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared input decoration ───────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
      prefixIcon: Icon(prefixIcon, size: 18, color: Colors.grey[500]),
      filled: true,
      fillColor: const Color(0xFFF8F8FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B4FE8), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}
