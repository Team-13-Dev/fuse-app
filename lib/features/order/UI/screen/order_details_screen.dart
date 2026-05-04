import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/features/order/UI/widgets/delete_order_bloc_listener.dart';
import 'package:fuse_system/features/order/data/model/order_response_model.dart';
import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderResponseModel order;
  const OrderDetailScreen({super.key, required this.order});

  static const _primary = Color(0xFF5046E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Order ID card
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                size: 18,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Order',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Order ID',
                          value: order.id,
                          isMonospace: true,
                        ),
                        const _Divider(),
                        _DetailRow(label: 'Date', value: order.createdAt),
                        const _Divider(),
                        _DetailRow(
                          label: 'Status',
                          value: order.status,
                          isStatus: true,
                        ),
                        const _Divider(),
                        _DetailRow(
                          label: 'Business ID',
                          value: order.businessId,
                          isMonospace: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Customer card
                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFE0E7FF),
                              child: Text(
                                _initials(order.customerName),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  order.customerEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const _Divider(),
                        const SizedBox(height: 4),
                        _DetailRow(
                          label: 'Customer ID',
                          value: order.customerId,
                          isMonospace: true,
                        ),
                        const _Divider(),
                        _DetailRow(label: 'Phone', value: order.customerPhone),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Total card
                  _Section(
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: 'EGP ${order.total}',
                        ),
                        const _Divider(),
                        _SummaryRow(
                          label: 'Discount',
                          value: '- EGP 0.00',
                          valueColor: const Color(0xFF15803D),
                        ),
                        const _Divider(),
                        _SummaryRow(
                          label: 'Total',
                          value: 'EGP ${order.total}',
                          bold: true,
                          valueColor: _primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  DeleteOrderBlocListener(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement delete functionality
                              context.read<OrderCubit>().deleteOrder(order.id);
                              // BlocProvider.value(
                              //   value: context.read<OrderCubit>(),
                              //   child: _showDeleteConfirmation(context),
                              // );
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFDC2626),
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement update status functionality
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Update Status',
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
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color _color() {
    switch (status.toLowerCase()) {
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

  Color _bg() {
    switch (status.toLowerCase()) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _color(),
        ),
      ),
    );
  }
}

// ── Reusable Section ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(height: 16, thickness: 1, color: Colors.grey.shade100);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;
  final bool isStatus;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: isStatus
              ? _StatusBadge(status: value)
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
