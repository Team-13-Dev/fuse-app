// // lib/features/order/UI/widgets/add_order_bottom_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fuse_system/core/Helpers/extensions.dart';
// import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
// import 'package:fuse_system/features/customer/logic/cubit/customer_state.dart';
// import 'package:fuse_system/features/order/data/model/add_order_request_model.dart';
// import 'package:fuse_system/features/order/logic/cubit/order_cubit.dart';
// import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';
// import 'package:fuse_system/features/product/logic/cubit/product_state.dart';

// class AddOrderBottomSheet extends StatefulWidget {
//   const AddOrderBottomSheet({super.key});

//   @override
//   State<AddOrderBottomSheet> createState() => _AddOrderBottomSheetState();
// }

// class _AddOrderBottomSheetState extends State<AddOrderBottomSheet>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _addressCtrl = TextEditingController();
//   final _orderVoucherCtrl = TextEditingController();
//   final _orderDiscountCtrl = TextEditingController(text: '0');

//   late AnimationController _animCtrl;
//   late Animation<double> _slideAnim;
//   late Animation<double> _fadeAnim;

//   String? _selectedCustomerId;
//   String? _selectedCustomerName;
//   final List<OrderItemModel> _orderItems = [];

//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _slideAnim = Tween<double>(
//       begin: 0.3,
//       end: 0.0,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

//     _fadeAnim = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

//     _animCtrl.forward();

//     // Fetch data
//     context.read<CustomerCubit>().fetchCustomers();
//     context.read<ProductCubit>().getProducts();
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _addressCtrl.dispose();
//     _orderVoucherCtrl.dispose();
//     _orderDiscountCtrl.dispose();
//     super.dispose();
//   }

//   double get _subtotal => _orderItems.fold(
//     0.0,
//     (sum, item) => sum + ((item.unitPrice * item.quantity) - item.itemDiscount),
//   );

//   double get _orderDiscount => double.tryParse(_orderDiscountCtrl.text) ?? 0.0;
//   double get _total => _subtotal - _orderDiscount;

//   void _addProduct(String id, String name, double price) {
//     final existing = _orderItems.firstWhere(
//       (item) => item.productId == id,
//       orElse: () => OrderItemModel(
//         productId: id,
//         productName: name,
//         unitPrice: price,
//         quantity: 0,
//         itemDiscount: 0.0,
//         attributes: null,
//       ),
//     );

//     setState(() {
//       if (existing.quantity > 0) {
//         existing.quantity++;
//       } else {
//         _orderItems.add(
//           OrderItemModel(
//             productId: id,
//             productName: name,
//             unitPrice: price,
//             quantity: 1,
//             itemDiscount: 0.0,
//             attributes: null,
//           ),
//         );
//       }
//     });
//   }

//   void _removeProduct(OrderItemModel item) {
//     setState(() {
//       if (item.quantity > 1) {
//         item.quantity--;
//       } else {
//         _orderItems.remove(item);
//       }
//     });
//   }

//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedCustomerId == null) {
//       _showError('Please select a customer');
//       return;
//     }
//     if (_orderItems.isEmpty) {
//       _showError('Please add at least one product');
//       return;
//     }
//     if (_addressCtrl.text.trim().isEmpty) {
//       _showError('Please enter delivery address');
//       return;
//     }

//     // Create order request
//     final request = AddOrderRequestModel(
//       customerId: _selectedCustomerId!,
//       address: _addressCtrl.text.trim(),
//       orderVoucher: _orderVoucherCtrl.text.trim().isEmpty
//           ? null
//           : _orderVoucherCtrl.text.trim(),
//       orderDiscount: _orderDiscount == 0
//           ? null
//           : _orderDiscount.toStringAsFixed(2),
//       items: _orderItems
//           .map(
//             (item) => OrderItemRequestModel(
//               productId: item.productId,
//               quantity: item.quantity,
//               unitPrice: item.unitPrice,
//               itemDiscount: item.itemDiscount,
//               attributes: item.attributes,
//             ),
//           )
//           .toList(),
//     );

//     context.read<OrderCubit>().createOrder(request);
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE17055),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottom = MediaQuery.of(context).viewInsets.bottom;

//     return FadeTransition(
//       opacity: _fadeAnim,
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, 0.3),
//           end: Offset.zero,
//         ).animate(_slideAnim),
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.9,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 _buildHandle(),
//                 _buildHeader(),
//                 const Divider(height: 1, color: Color(0xFFEEEEF5)),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildOrderPreview(),
//                         const SizedBox(height: 24),
//                         _buildCustomerSection(),
//                         const SizedBox(height: 24),
//                         _buildAddressSection(),
//                         const SizedBox(height: 24),
//                         _buildProductsSection(),
//                         const SizedBox(height: 24),
//                         _buildDiscountSection(),
//                         const SizedBox(height: 24),
//                         _buildPricingSummary(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _buildActions(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHandle() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.only(top: 12, bottom: 8),
//         width: 40,
//         height: 4,
//         decoration: BoxDecoration(
//           color: const Color(0xFFDDDDE8),
//           borderRadius: BorderRadius.circular(2),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 4, 16, 16),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.shopping_cart_outlined,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Create New Order',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF1A1A2E),
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   'Add products and complete order details',
//                   style: TextStyle(fontSize: 12, color: Color(0xFF888899)),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => context.pop(),
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F6FA),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 size: 18,
//                 color: Color(0xFF888899),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderPreview() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF5B4FE8).withOpacity(0.1),
//             const Color(0xFF7B6FF0).withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF5B4FE8).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildPreviewStat(
//                   'Items',
//                   '${_orderItems.fold(0, (sum, item) => sum + item.quantity)}',
//                   Icons.inventory_2_outlined,
//                   const Color(0xFF5B4FE8),
//                 ),
//               ),
//               Container(width: 1, height: 40, color: const Color(0xFFEEEEF5)),
//               Expanded(
//                 child: _buildPreviewStat(
//                   'Total',
//                   'EGP ${_total.toStringAsFixed(2)}',
//                   Icons.attach_money,
//                   const Color(0xFF00B894),
//                 ),
//               ),
//             ],
//           ),
//           if (_orderItems.isNotEmpty) ...[
//             const Divider(height: 24),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF5B4FE8).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.person_outline,
//                     size: 16,
//                     color: Color(0xFF5B4FE8),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     _selectedCustomerName ?? 'No customer selected',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: _selectedCustomerName != null
//                           ? const Color(0xFF1A1A2E)
//                           : const Color(0xFFBBBBCC),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewStat(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Icon(icon, size: 20, color: color),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             color: Color(0xFF1A1A2E),
//           ),
//         ),
//         Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
//       ],
//     );
//   }

//   Widget _buildCustomerSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Customer', required: true),
//         const SizedBox(height: 10),
//         BlocBuilder<CustomerCubit, CustomerState>(
//           builder: (context, state) {
//             return state.maybeWhen(
//               success: (customers) => _buildCustomerSelector(customers),
//               loading: () => const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//               orElse: () => _buildCustomerSelector([]),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomerSelector(List customers) {
//     return GestureDetector(
//       onTap: () => _showCustomerPicker(customers),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8F8FF),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: _selectedCustomerId != null
//                 ? const Color(0xFF5B4FE8).withOpacity(0.3)
//                 : const Color(0xFFE8E8F0),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: _selectedCustomerId != null
//                     ? const Color(0xFF5B4FE8)
//                     : const Color(0xFFE8E8F0),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 Icons.person,
//                 color: _selectedCustomerId != null
//                     ? Colors.white
//                     : const Color(0xFFBBBBCC),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 _selectedCustomerName ?? 'Select customer',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: _selectedCustomerId != null
//                       ? const Color(0xFF1A1A2E)
//                       : const Color(0xFFBBBBCC),
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCustomerPicker(List customers) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   const Text(
//                     'Select Customer',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: customers.length,
//                 itemBuilder: (context, index) {
//                   final customer = customers[index];
//                   return _buildCustomerTile(customer);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerTile(customer) {
//     final isSelected = _selectedCustomerId == customer.id;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedCustomerId = customer.id;
//           _selectedCustomerName = customer.fullName;
//         });
//         Navigator.pop(context);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? const Color(0xFF5B4FE8).withOpacity(0.1)
//               : const Color(0xFFF8F8FF),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected
//                 ? const Color(0xFF5B4FE8)
//                 : const Color(0xFFE8E8F0),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5B4FE8),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: Text(
//                   customer.fullName[0].toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     customer.fullName,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     customer.email,
//                     style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               const Icon(
//                 Icons.check_circle,
//                 color: Color(0xFF5B4FE8),
//                 size: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddressSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Delivery Address', required: true),
//         const SizedBox(height: 10),
//         TextFormField(
//           controller: _addressCtrl,
//           maxLines: 2,
//           style: const TextStyle(fontSize: 13),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Address is required';
//             }
//             return null;
//           },
//           decoration: InputDecoration(
//             hintText: 'Enter delivery address...',
//             hintStyle: const TextStyle(color: Color(0xFFBBBBCC), fontSize: 13),
//             filled: true,
//             fillColor: const Color(0xFFF8F8FF),
//             contentPadding: const EdgeInsets.all(14),
//             prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Color(0xFF5B4FE8),
//                 width: 1.5,
//               ),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFEF4444)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             _sectionLabel('Products', required: true),
//             const Spacer(),
//             TextButton.icon(
//               onPressed: () => _showProductPicker(),
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text('Add Product'),
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFF5B4FE8),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         if (_orderItems.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8FF),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: const Color(0xFFE8E8F0),
//                 style: BorderStyle.solid,
//                 strokeAlign: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.shopping_cart_outlined,
//                   size: 48,
//                   color: Colors.grey[300],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'No products added yet',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 ),
//               ],
//             ),
//           )
//         else
//           ..._orderItems.map((item) => _buildOrderItemCard(item)),
//       ],
//     );
//   }

//   void _showProductPicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => BlocProvider.value(
//         value: context.read<ProductCubit>(),
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.7,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     const Text(
//                       'Select Products',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1),
//               Expanded(
//                 child: BlocBuilder<ProductCubit, ProductState>(
//                   builder: (context, state) {
//                     return state.maybeWhen(
//                       success: (products) => ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: products.length,
//                         itemBuilder: (context, index) {
//                           final product = products[index];
//                           return _buildProductTile(product);
//                         },
//                       ),
//                       loading: () =>
//                           const Center(child: CircularProgressIndicator()),
//                       orElse: () => const SizedBox(),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductTile(product) {
//     return GestureDetector(
//       onTap: () {
//         _addProduct(
//           product.id,
//           product.name,
//           double.parse(product.price.toString()),
//         );
//         Navigator.pop(context);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8F8FF),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFE8E8F0)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5B4FE8).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.inventory_2_outlined,
//                 color: Color(0xFF5B4FE8),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     'EGP ${product.price}',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF00B894),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.add_circle_outline, color: Color(0xFF5B4FE8)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderItemCard(OrderItemModel item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFE8E8F0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.inventory_2,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.productName,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'EGP ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'EGP ${((item.unitPrice * item.quantity) - item.itemDiscount).toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF00B894),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       _quantityButton(Icons.remove, () => _removeProduct(item)),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           '${item.quantity}',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                       _quantityButton(
//                         Icons.add,
//                         () => setState(() => item.quantity++),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           if (item.itemDiscount > 0) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00B894).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.discount,
//                     size: 16,
//                     color: Color(0xFF00B894),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Item discount: EGP ${item.itemDiscount.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF00B894),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton.icon(
//                   onPressed: () => _showItemDiscountDialog(item),
//                   icon: const Icon(Icons.discount, size: 16),
//                   label: const Text('Discount', style: TextStyle(fontSize: 12)),
//                   style: TextButton.styleFrom(
//                     foregroundColor: const Color(0xFF00B894),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ),
//               Container(width: 1, height: 20, color: const Color(0xFFE8E8F0)),
//               Expanded(
//                 child: TextButton.icon(
//                   onPressed: () => _showAttributesDialog(item),
//                   icon: const Icon(Icons.tune, size: 16),
//                   label: const Text(
//                     'Attributes',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                   style: TextButton.styleFrom(
//                     foregroundColor: const Color(0xFF5B4FE8),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showItemDiscountDialog(OrderItemModel item) {
//     final controller = TextEditingController(
//       text: item.itemDiscount.toStringAsFixed(2),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Item Discount'),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(
//             labelText: 'Discount Amount (EGP)',
//             prefixText: 'EGP ',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 item.itemDiscount = double.tryParse(controller.text) ?? 0.0;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAttributesDialog(OrderItemModel item) {
//     final sizeController = TextEditingController(text: item.attributes?.size);
//     final colorController = TextEditingController(text: item.attributes?.color);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Product Attributes'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: sizeController,
//               decoration: const InputDecoration(
//                 labelText: 'Size (Optional)',
//                 hintText: 'e.g., M, L, XL',
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: colorController,
//               decoration: const InputDecoration(
//                 labelText: 'Color (Optional)',
//                 hintText: 'e.g., Red, Blue',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 if (sizeController.text.isEmpty &&
//                     colorController.text.isEmpty) {
//                   item.attributes = null;
//                 } else {
//                   item.attributes = Attributes(
//                     size: sizeController.text.isEmpty
//                         ? null
//                         : sizeController.text,
//                     color: colorController.text.isEmpty
//                         ? null
//                         : colorController.text,
//                   );
//                 }
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _quantityButton(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 28,
//         height: 28,
//         decoration: BoxDecoration(
//           color: const Color(0xFF5B4FE8).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, size: 16, color: const Color(0xFF5B4FE8)),
//       ),
//     );
//   }

//   Widget _buildDiscountSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Discounts & Vouchers'),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _orderVoucherCtrl,
//           style: const TextStyle(fontSize: 13),
//           decoration: InputDecoration(
//             labelText: 'Voucher Code (Optional)',
//             hintText: 'Enter voucher code...',
//             hintStyle: const TextStyle(color: Color(0xFFBBBBCC), fontSize: 13),
//             filled: true,
//             fillColor: const Color(0xFFF8F8FF),
//             contentPadding: const EdgeInsets.all(14),
//             prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Color(0xFF5B4FE8),
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _orderDiscountCtrl,
//           keyboardType: TextInputType.number,
//           style: const TextStyle(fontSize: 13),
//           onChanged: (_) => setState(() {}),
//           decoration: InputDecoration(
//             labelText: 'Order Discount (EGP)',
//             hintText: '0.00',
//             hintStyle: const TextStyle(color: Color(0xFFBBBBCC), fontSize: 13),
//             filled: true,
//             fillColor: const Color(0xFFF8F8FF),
//             contentPadding: const EdgeInsets.all(14),
//             prefixIcon: const Icon(Icons.discount_outlined, size: 20),
//             prefixText: 'EGP ',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: Color(0xFF5B4FE8),
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPricingSummary() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF5B4FE8).withOpacity(0.05),
//             const Color(0xFF7B6FF0).withOpacity(0.02),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF5B4FE8).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           _pricingRow('Subtotal', 'EGP ${_subtotal.toStringAsFixed(2)}'),
//           if (_orderDiscount > 0) ...[
//             const SizedBox(height: 12),
//             _pricingRow(
//               'Order Discount',
//               '- EGP ${_orderDiscount.toStringAsFixed(2)}',
//               color: const Color(0xFFEF4444),
//             ),
//           ],
//           const Divider(height: 24),
//           _pricingRow(
//             'Total',
//             'EGP ${_total.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _pricingRow(
//     String label,
//     String value, {
//     bool isTotal = false,
//     Color? color,
//   }) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//             color:
//                 color ??
//                 (isTotal ? const Color(0xFF1A1A2E) : const Color(0xFF888899)),
//           ),
//         ),
//         const Spacer(),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: isTotal ? 20 : 14,
//             fontWeight: FontWeight.w800,
//             color:
//                 color ??
//                 (isTotal ? const Color(0xFF5B4FE8) : const Color(0xFF1A1A2E)),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActions() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Color(0xFFEEEEF5))),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () => context.pop(),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 side: const BorderSide(color: Color(0xFFE8E8F0)),
//                 foregroundColor: const Color(0xFF888899),
//               ),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF5B4FE8),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check_circle_outline, size: 18),
//                   SizedBox(width: 8),
//                   Text(
//                     'Create Order',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionLabel(String text, {bool required = false}) {
//     return Row(
//       children: [
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF1A1A2E),
//           ),
//         ),
//         if (required) ...[
//           const SizedBox(width: 4),
//           const Text(
//             '*',
//             style: TextStyle(color: Color(0xFFEF4444), fontSize: 15),
//           ),
//         ],
//       ],
//     );
//   }
// }

// // Helper class matching OrderItemRequestModel
// class OrderItemModel {
//   final String productId;
//   final String productName;
//   final double unitPrice;
//   int quantity;
//   double itemDiscount;
//   Attributes? attributes;

//   OrderItemModel({
//     required this.productId,
//     required this.productName,
//     required this.unitPrice,
//     required this.quantity,
//     required this.itemDiscount,
//     this.attributes,
//   });
// }
