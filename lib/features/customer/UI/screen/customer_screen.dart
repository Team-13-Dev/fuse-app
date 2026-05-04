// ─────────────────────────────────────────────
// customers_page.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/core/di/dependency_injection.dart';
import 'package:fuse_system/features/customer/UI/screen/customer_details_screen.dart';
import 'package:fuse_system/features/customer/UI/widgets/add_customer_bloc_listener.dart';
import 'package:fuse_system/features/customer/data/model/customer_request_model.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_state.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_app_bar.dart';
import 'package:fuse_system/features/drawer_navigation/UI/screen/fuse_drawer_navigation_screen.dart';

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

Color _avatarColorFor(String fullName) {
  const colors = [
    Color(0xFF5B4FE9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];
  return colors[fullName.length % colors.length];
}

String _initialsFor(String fullName) {
  final parts = fullName.trim().split(' ');
  if (parts.length >= 2 && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
}

Color _segmentColor(String? segment) {
  switch (segment) {
    case 'VIP':
      return const Color(0xFF5B4FE9);
    case 'Regular':
      return const Color(0xFF10B981);
    case 'New':
      return const Color(0xFF3B82F6);
    case 'At-risk':
      return const Color(0xFFEF4444);
    default:
      return Colors.grey;
  }
}

// ─────────────────────────────────────────────
// ADD CUSTOMER BOTTOM SHEET
// ─────────────────────────────────────────────

class AddCustomerSheet extends StatefulWidget {
  const AddCustomerSheet({super.key});

  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameFocus = FocusNode();

  String _selectedSegment = 'New';
  bool _showAdvanced = false;

  late AnimationController _animCtrl;
  late Animation<double> _anim;

  final _segments = ['New', 'Regular', 'VIP', 'At-risk', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FocusScope.of(context).requestFocus(_nameFocus),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerCubit>().createCustomer(
      CustomerRequestModel(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        segment: _selectedSegment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, .25),
        end: Offset.zero,
      ).animate(_anim),
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: EdgeInsets.only(bottom: bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _handle(),
                _header(),
                const Divider(height: 1, color: Color(0xFFEEEEF5)),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _preview(),
                        const SizedBox(height: 20),
                        _label('Full name', required: true),
                        const SizedBox(height: 6),
                        _field(
                          ctrl: _nameCtrl,
                          focus: _nameFocus,
                          hint: 'e.g. Sara Ali',
                          onChange: (_) => setState(() {}),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Email'),
                                  const SizedBox(height: 6),
                                  _field(
                                    ctrl: _emailCtrl,
                                    hint: 'name@example.com',
                                    keyboard: TextInputType.emailAddress,
                                    onChange: (_) => setState(() {}),
                                    validator: (v) =>
                                        (v != null &&
                                            v.isNotEmpty &&
                                            !v.contains('@'))
                                        ? 'Invalid email'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Phone'),
                                  const SizedBox(height: 6),
                                  _field(
                                    ctrl: _phoneCtrl,
                                    hint: '+20 1...',
                                    keyboard: TextInputType.phone,
                                    formatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+\s\-()]'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _label('Segment'),
                        const SizedBox(height: 8),
                        _segmentPicker(),
                        const SizedBox(height: 16),
                        _advancedToggle(),
                        if (_showAdvanced) ...[
                          const SizedBox(height: 14),
                          _advancedSection(),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle() => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDE8),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 16, 16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add new customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fill in the details to create a new customer record.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF888899),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _preview() {
    final name = _nameCtrl.text.trim();
    final hasName = name.isNotEmpty;
    final initials = hasName ? _initialsFor(name) : '?';
    final color = hasName ? _avatarColorFor(name) : const Color(0xFFDDDDE8);
    final sc = _segmentColor(_selectedSegment);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEF5)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: hasName
                  ? [
                      BoxShadow(
                        color: color.withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? name : 'Customer name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: hasName
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFFCCCCDD),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _emailCtrl.text.isEmpty
                      ? 'email will appear here'
                      : _emailCtrl.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: _emailCtrl.text.isEmpty
                        ? const Color(0xFFCCCCDD)
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: sc.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sc.withOpacity(.3)),
            ),
            child: Text(
              _selectedSegment,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: sc,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Row(
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
      if (required) ...[
        const SizedBox(width: 3),
        const Text(
          '*',
          style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
        ),
      ],
    ],
  );

  Widget _field({
    required TextEditingController ctrl,
    FocusNode? focus,
    required String hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    void Function(String)? onChange,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    focusNode: focus,
    keyboardType: keyboard,
    inputFormatters: formatters,
    onChanged: onChange,
    validator: validator,
    style: const TextStyle(
      fontSize: 14,
      color: Color(0xFF1A1A2E),
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBCC), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8F8FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B4FE9), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    ),
  );

  Widget _segmentPicker() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _segments.map((seg) {
      final sel = _selectedSegment == seg;
      final c = _segmentColor(seg);
      return GestureDetector(
        onTap: () => setState(() => _selectedSegment = seg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: sel ? c : const Color(0xFFF8F8FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? c : const Color(0xFFE8E8F0),
              width: sel ? 1.5 : 1,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: c.withOpacity(.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sel) ...[
                const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                seg,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : const Color(0xFF888899),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _advancedToggle() => GestureDetector(
    onTap: () => setState(() => _showAdvanced = !_showAdvanced),
    child: Row(
      children: [
        AnimatedRotation(
          turns: _showAdvanced ? .25 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Color(0xFF5B4FE9),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'Advanced',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B4FE9),
          ),
        ),
      ],
    ),
  );

  Widget _advancedSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Notes'),
      const SizedBox(height: 6),
      TextFormField(
        maxLines: 3,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: 'Internal notes about this customer...',
          hintStyle: const TextStyle(color: Color(0xFFBBBBCC), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF8F8FF),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF5B4FE9), width: 1.5),
          ),
        ),
      ),
    ],
  );

  Widget _actions() => AddCustomerBlocListener(
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEF5))),
      ),
      child: BlocBuilder<CustomerCubit, CustomerState>(
        buildWhen: (prev, curr) =>
            curr.maybeWhen(
              loading: () => true,
              successCreate: (_) => true,
              error: (_) => true,
              orElse: () => false,
            ) ||
            prev.maybeWhen(loading: () => true, orElse: () => false),
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFE8E8F0)),
                    foregroundColor: const Color(0xFF888899),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FE9),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF5B4FE9,
                    ).withOpacity(.6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_rounded, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Add customer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// CUSTOMER CARD
// ─────────────────────────────────────────────

class CustomerCard extends StatefulWidget {
  final CustomerResponseModel customer;
  final void Function()? onTap;
  const CustomerCard({super.key, required this.customer, required this.onTap});

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    final tc = _segmentColor(c.segment);
    final avatarColor = _avatarColorFor(c.fullName);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFF0EFFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed
                ? const Color(0xFF5B4FE9).withOpacity(.3)
                : const Color(0xFFEEEEF5),
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withOpacity(.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initialsFor(c.fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888899),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (c.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      c.phoneNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tc.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.segment ?? 'None',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: tc,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFFCCCCDD),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    context.read<CustomerCubit>().fetchCustomers();
    // NOTE: No scroll listener — pagination is now manual (page number buttons)
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.45),
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: const AddCustomerSheet(),
      ),
    );
  }

  // ── Navigate to a specific page ───────────────────────────────────────────
  void _goToPage(CustomerCubit cubit, int page) {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    cubit.goToPage(page);
  }

  // ── Smart page list with ellipsis (-1 = sentinel for '…') ────────────────
  List<int> _buildPageList(int current, int total) {
    if (total <= 7) return List.generate(total, (i) => i + 1);

    final pages = <int>[];
    pages.add(1);
    if (current > 3) pages.add(-1);

    final start = (current - 1).clamp(2, total - 1);
    final end = (current + 1).clamp(2, total - 1);
    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    if (current < total - 2) pages.add(-1);
    pages.add(total);

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: const FuseDrawer(activeItem: 'Customers'),
      appBar: FuseAppBar(currentPage: 'Customers'),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: BlocBuilder<CustomerCubit, CustomerState>(
            buildWhen: (_, curr) => curr.maybeWhen(
              initial: () => true,
              loading: () => true,
              success: (_) => true,
              error: (_) => true,
              orElse: () => false,
            ),
            builder: (context, state) => state.maybeWhen(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF5B4FE9)),
              ),
              success: (customers) => _body(customers),
              error: (error) => _errorView(error.toString()),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  // ── ERROR VIEW ────────────────────────────────────────────────────────────
  Widget _errorView(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: Color(0xFFCCCCDD),
          ),
          const SizedBox(height: 12),
          const Text(
            'Failed to load customers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888899)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<CustomerCubit>().fetchCustomers(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4FE9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── SCROLLABLE BODY ───────────────────────────────────────────────────────
  Widget _body(List<CustomerResponseModel> customers) {
    final cubit = context.read<CustomerCubit>();

    final vip = customers.where((c) => c.segment == 'VIP').length;
    final risk = customers.where((c) => c.segment == 'At-risk').length;
    final cov = customers.isEmpty
        ? 0
        : (customers.where((c) => c.email.isNotEmpty).length /
                  customers.length *
                  100)
              .round();

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _pageHeader()),
        SliverToBoxAdapter(child: _addBtn()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: _statsGrid(
            total: customers.length,
            vip: vip,
            risk: risk,
            cov: cov,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(child: _listHeader(customers.length, cubit)),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // ── Customer cards ────────────────────────────────────────────────
        if (customers.isEmpty)
          SliverToBoxAdapter(child: _emptyView())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => CustomerCard(
                customer: customers[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: getIt<CustomerCubit>(),
                      child: CustomerDetailsScreen(customer: customers[i]),
                    ),
                  ),
                ),
              ),
              childCount: customers.length,
            ),
          ),

        // ── Pagination footer ─────────────────────────────────────────────
        SliverToBoxAdapter(child: _paginationFooter(cubit, customers.length)),
      ],
    );
  }

  // ── PAGE HEADER ──────────────────────────────────────────────────────────
  Widget _pageHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customers',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your customer base, segments, and contact info.',
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.grey[500],
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  // ── ADD BUTTON ───────────────────────────────────────────────────────────
  Widget _addBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: const Text(
          'Add customer',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B4FE9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    ),
  );

  // ── STATS GRID ───────────────────────────────────────────────────────────
  Widget _statsGrid({
    required int total,
    required int vip,
    required int risk,
    required int cov,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: _totalCard(total)),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'VIP',
                '$vip',
                'Top tier segment',
                Icons.shield_outlined,
                Colors.white,
                const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'AT-RISK',
                '$risk',
                'Need attention',
                Icons.info_outline_rounded,
                const Color(0xFFF5F6FA),
                const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'CONTACT\nCOVERAGE',
                '$cov%',
                'Have email on file',
                Icons.trending_up_rounded,
                const Color(0xFFF5F6FA),
                const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _totalCard(int total) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF5B4FE9),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF5B4FE9).withOpacity(.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
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
              'TOTAL\nCUSTOMERS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: .8,
                height: 1.4,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '$total',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ],
    ),
  );

  Widget _statCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color bg,
    Color text,
  ) {
    final light = bg == Colors.white || bg == const Color(0xFFF5F6FA);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: light ? Border.all(color: const Color(0xFFE8E8F0)) : null,
        boxShadow: light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: text.withOpacity(.5),
                  letterSpacing: .8,
                  height: 1.4,
                ),
              ),
              Icon(icon, color: text.withOpacity(.4), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: text,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: text.withOpacity(.45),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── LIST HEADER (search + refresh) ───────────────────────────────────────
  Widget _listHeader(int total, CustomerCubit cubit) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          children: [
            Text(
              'All customers ($total)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() {});
                cubit.fetchCustomers();
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Color(0xFF888899),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Search ───────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE8E8F0)),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) {
              setState(() {});
              cubit.searchCustomers(v);
            },
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search customers...',
              hintStyle: const TextStyle(
                color: Color(0xFFBBBBCC),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Color(0xFFBBBBCC),
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() {});
                        cubit.fetchCustomers();
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFBBBBCC),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
    ],
  );

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _emptyView() => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No customers found',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    ),
  );

  // ── PAGINATION FOOTER ─────────────────────────────────────────────────────
  Widget _paginationFooter(CustomerCubit cubit, int totalLoaded) {
    final current = cubit.currentPage;
    final total = cubit.totalPages;

    // Single page — just show a label
    if (total <= 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'All $totalLoaded customers loaded',
            style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBCC)),
          ),
        ),
      );
    }

    final pages = _buildPageList(current, total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          // ── Page info label ─────────────────────────────────────────────
          Text(
            'Page $current of $total  •  $totalLoaded customers',
            style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBCC)),
          ),
          const SizedBox(height: 12),

          // ── Prev / page chips / Next ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Prev arrow
              _pageArrowBtn(
                icon: Icons.chevron_left_rounded,
                enabled: current > 1,
                onTap: () => _goToPage(cubit, current - 1),
              ),
              const SizedBox(width: 6),

              // Page number chips
              ...pages.map((p) {
                // Ellipsis sentinel
                if (p == -1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '…',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFBBBBCC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final isActive = p == current;
                return GestureDetector(
                  onTap: isActive ? null : () => _goToPage(cubit, p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF5B4FE9) : Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF5B4FE9)
                            : const Color(0xFFE8E8F0),
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF5B4FE9).withOpacity(.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '$p',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF888899),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 6),
              // Next arrow
              _pageArrowBtn(
                icon: Icons.chevron_right_rounded,
                enabled: current < total,
                onTap: () => _goToPage(cubit, current + 1),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Jump to page ────────────────────────────────────────────────
          _JumpToPage(totalPages: total, onJump: (p) => _goToPage(cubit, p)),
        ],
      ),
    );
  }

  Widget _pageArrowBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE8E8F0)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF5B4FE9) : const Color(0xFFCCCCDD),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// JUMP TO PAGE WIDGET
// ─────────────────────────────────────────────

class _JumpToPage extends StatefulWidget {
  final int totalPages;
  final void Function(int page) onJump;

  const _JumpToPage({required this.totalPages, required this.onJump});

  @override
  State<_JumpToPage> createState() => _JumpToPageState();
}

class _JumpToPageState extends State<_JumpToPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final val = int.tryParse(_ctrl.text.trim());
    if (val == null || val < 1 || val > widget.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a page between 1 and ${widget.totalPages}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    _ctrl.clear();
    FocusScope.of(context).unfocus();
    widget.onJump(val);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Go to page',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF888899),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),

        // Number input
        SizedBox(
          width: 52,
          height: 34,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _submit(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              hintText: '#',
              hintStyle: const TextStyle(
                color: Color(0xFFCCCCDD),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFF5B4FE9),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Go button
        GestureDetector(
          onTap: _submit,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF5B4FE9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text(
                'Go',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
