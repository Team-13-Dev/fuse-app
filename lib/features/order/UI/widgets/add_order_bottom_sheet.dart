import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/customer/data/model/customer_response_model.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_state.dart';
import 'package:fuse_system/features/order/data/model/add_order_request_model.dart';
import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';
import 'package:fuse_system/features/order/logic/cubit/order_state.dart';
import 'package:fuse_system/features/product/data/model/product_response_model.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';
import 'package:fuse_system/features/product/logic/cubit/product_state.dart';
import 'dart:async';

class AddOrderBottomSheet extends StatefulWidget {
  const AddOrderBottomSheet({super.key});

  @override
  State<AddOrderBottomSheet> createState() => _AddOrderBottomSheetState();
}

class _AddOrderBottomSheetState extends State<AddOrderBottomSheet>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF5046E5);

  CustomerResponseModel? _selectedCustomer;
  final Map<String, _CartItem> _cart = {};

  final _custCtrl = TextEditingController();
  final _prodCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Timer? _searchDebounce;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
    context.read<ProductCubit>().getProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _custCtrl.dispose();
    _prodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _total => _cart.values.fold(0, (s, i) => s + i.unitPrice * i.qty);
  bool get _canCreate =>
      _selectedCustomer != null && _cart.isNotEmpty && !_isSubmitting;

  void _onSearchChanged(String query, void Function(String) searchFn) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      searchFn(query);
    });
  }

  void _addProduct(ProductResponseModel p) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_cart.containsKey(p.id)) {
        _cart[p.id] = _cart[p.id]!.copyWith(qty: _cart[p.id]!.qty + 1);
      } else {
        _cart[p.id] = _CartItem(
          productId: p.id,
          name: p.name,
          unitPrice: double.tryParse(p.price) ?? 0,
          qty: 1,
        );
      }
      _prodCtrl.clear();
    });
  }

  void _updateQty(String productId, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_cart.containsKey(productId)) return;
      final newQty = _cart[productId]!.qty + delta;
      if (newQty <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId] = _cart[productId]!.copyWith(qty: newQty);
      }
    });
  }

  void _removeItem(String productId) {
    HapticFeedback.mediumImpact();
    setState(() => _cart.remove(productId));
  }

  void _selectCustomer(CustomerResponseModel c) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCustomer = c;
      _custCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _submit() async {
    if (!_canCreate) return;
    HapticFeedback.heavyImpact();
    setState(() => _isSubmitting = true);

    context.read<OrderCubit>().createOrder(
      AddOrderRequestModel(
        customerId: _selectedCustomer!.id,
        address: _notesCtrl.text.trim(),
        items: _cart.values
            .map(
              (i) => OrderItemRequestModel(
                productId: i.productId,
                quantity: i.qty,
                unitPrice: i.unitPrice,
                itemDiscount: 0,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (_) {},
          successDelete: () {},

          // ✅ On success: pop with `true` so OrdersScreen knows to refresh.
          //    Do NOT call fetchOrders() here — OrdersScreen handles that.
          successCreate: (_) {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          },

          error: (errorHandler) {
            if (mounted) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorHandler.apiErrorModel.error.isNotEmpty
                        ? errorHandler.apiErrorModel.error
                        : 'Failed to create order. Please try again.',
                  ),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
        );
      },

      // ✅ DraggableScrollableSheet with no SlideTransition wrapper.
      //    The sheet's Container has color: Colors.white — this is what the
      //    user sees. showModalBottomSheet must use backgroundColor: Colors.transparent
      //    (set in OrdersScreen._openAddOrder) so this white container is not hidden.
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors
                  .white, // ✅ opaque white — visible when modal bg is transparent
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 30,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Drag Handle ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 14, bottom: 10),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primary.withOpacity(0.1),
                              _primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: _primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Order',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Add customer and products',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ── Scrollable Content ───────────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildCustomerSection(),
                      const SizedBox(height: 24),
                      _buildProductsSection(),
                      const SizedBox(height: 24),
                      if (_cart.isNotEmpty) ...[
                        _buildCartSection(),
                        const SizedBox(height: 24),
                      ],
                      _buildNotesSection(),
                      const SizedBox(height: 24),
                      if (_cart.isNotEmpty) ...[
                        _buildTotalSection(),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Customer Section ──────────────────────────────────────────────────────

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'REQUIRED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Select Customer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedCustomer != null)
          _SelectedCustomerCard(
            customer: _selectedCustomer!,
            onRemove: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCustomer = null);
            },
          )
        else
          _CustomerSearch(
            controller: _custCtrl,
            onChanged: (q) => _onSearchChanged(
              q,
              (query) => context.read<CustomerCubit>().searchCustomers(query),
            ),
            onSelect: _selectCustomer,
          ),
      ],
    );
  }

  // ── Products Section ──────────────────────────────────────────────────────

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Text(
              'Add Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProductSearch(controller: _prodCtrl, onSelect: _addProduct),
      ],
    );
  }

  // ── Cart Section ──────────────────────────────────────────────────────────

  Widget _buildCartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 18,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_cart.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _cart.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Colors.grey.shade100),
                _CartItemTile(
                  item: _cart.values.elementAt(i),
                  onIncrease: () => _updateQty(_cart.keys.elementAt(i), 1),
                  onDecrease: () => _updateQty(_cart.keys.elementAt(i), -1),
                  onRemove: () => _removeItem(_cart.keys.elementAt(i)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Notes Section ─────────────────────────────────────────────────────────

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.note_outlined, size: 18, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Text(
              'Delivery Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(width: 6),
            Text(
              '(Optional)',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _notesCtrl,
            maxLines: 4,
            maxLength: 200,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: 'e.g., Deliver between 2-4 PM, Ring doorbell twice...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Total Section ─────────────────────────────────────────────────────────

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary.withOpacity(0.08), _primary.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                'EGP ${_total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _total),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Text(
                    'EGP ${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canCreate ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                elevation: _canCreate ? 4 : 0,
                shadowColor: _primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Create Order',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Models
// ══════════════════════════════════════════════════════════════════════════════

class _CartItem {
  final String productId;
  final String name;
  final double unitPrice;
  final int qty;

  const _CartItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.qty,
  });

  _CartItem copyWith({int? qty}) => _CartItem(
    productId: productId,
    name: name,
    unitPrice: unitPrice,
    qty: qty ?? this.qty,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

class _SelectedCustomerCard extends StatelessWidget {
  final CustomerResponseModel customer;
  final VoidCallback onRemove;

  const _SelectedCustomerCard({required this.customer, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5046E5).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5046E5).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(name: customer.fullName, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          customer.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSearch extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Function(CustomerResponseModel) onSelect;

  const _CustomerSearch({
    required this.controller,
    required this.onChanged,
    required this.onSelect,
  });

  @override
  State<_CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<_CustomerSearch> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(
          controller: widget.controller,
          hint: 'Search by name or email...',
          icon: Icons.person_search,
          onChanged: (q) {
            widget.onChanged(q);
            setState(() => _isOpen = q.isNotEmpty);
          },
          onTap: () => setState(() => _isOpen = true),
          onClear: () {
            widget.controller.clear();
            widget.onChanged('');
            setState(() => _isOpen = false);
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _isOpen
              ? BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) => state.maybeWhen(
                    loading: () => const _LoadingCard(),
                    success: (customers) => _ResultsCard(
                      itemCount: customers.length,
                      itemBuilder: (index) {
                        final customer = customers[index];
                        return _CustomerTile(
                          customer: customer,
                          onTap: () {
                            widget.onSelect(customer);
                            setState(() => _isOpen = false);
                          },
                        );
                      },
                      emptyMessage: 'No customers found',
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ProductSearch extends StatefulWidget {
  final TextEditingController controller;
  final Function(ProductResponseModel) onSelect;

  const _ProductSearch({required this.controller, required this.onSelect});

  @override
  State<_ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<_ProductSearch> {
  bool _isOpen = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchField(
          controller: widget.controller,
          hint: 'Search products...',
          icon: Icons.search,
          onChanged: (q) {
            setState(() {
              _query = q.toLowerCase();
              _isOpen = true;
            });
          },
          onTap: () => setState(() => _isOpen = true),
          onClear: () {
            widget.controller.clear();
            setState(() {
              _query = '';
              _isOpen = false;
            });
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _isOpen
              ? BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) => state.maybeWhen(
                    loading: () => const _LoadingCard(),
                    success: (products) {
                      final filtered = _query.isEmpty
                          ? products
                          : products
                                .where(
                                  (p) => p.name.toLowerCase().contains(_query),
                                )
                                .toList();
                      return _ResultsCard(
                        itemCount: filtered.length,
                        itemBuilder: (index) {
                          final product = filtered[index];
                          return _ProductTile(
                            product: product,
                            onTap: () {
                              widget.onSelect(product);
                              setState(() => _isOpen = false);
                            },
                          );
                        },
                        emptyMessage: 'No products found',
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(icon, size: 22, color: Colors.grey.shade400),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                )
              : null,
          border: InputBorder.none,
          filled: false,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final int itemCount;
  final Widget Function(int) itemBuilder;
  final String emptyMessage;

  const _ResultsCard({
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: itemCount,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey.shade100),
          itemBuilder: (_, i) => itemBuilder(i),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF5046E5),
          ),
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final CustomerResponseModel customer;
  final VoidCallback onTap;

  const _CustomerTile({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Avatar(name: customer.fullName, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductResponseModel product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 22,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'EGP ${product.price} / unit',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF5046E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: [
                      Text(
                        'EGP ${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5046E5),
                        ),
                      ),
                      Text(
                        '× ${item.qty}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '= EGP ${(item.unitPrice * item.qty).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(
                    icon: Icons.remove_rounded,
                    onTap: onDecrease,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.qty}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  _QuantityButton(icon: Icons.add_rounded, onTap: onIncrease),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;

  const _Avatar({required this.name, required this.size});

  String _initials() {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0E7FF), Color(0xFFDDD6FE)],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF5046E5).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _initials(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5046E5),
          ),
        ),
      ),
    );
  }
}
