// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fuse_system/features/product/UI/widgets/add_product_bloc_listener.dart';
// import 'package:fuse_system/features/product/logic/cubit/add_product_cubit.dart';
// import 'package:fuse_system/features/product/logic/cubit/add_product_state.dart';

// class AddProductDialog extends StatefulWidget {
//   final VoidCallback onProductAdded;

//   const AddProductDialog({Key? key, required this.onProductAdded})
//     : super(key: key);

//   @override
//   State<AddProductDialog> createState() => _AddProductDialogState();
// }

// class _AddProductDialogState extends State<AddProductDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _costController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _costController.dispose();
//     _stockController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AddProductBlocListener(
//       onSuccess: () {
//         Navigator.of(context).pop();
//         widget.onProductAdded();
//       },
//       child: Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 520,
//           padding: const EdgeInsets.all(24),
//           child: BlocBuilder<AddProductCubit, AddProductState>(
//             builder: (context, state) {
//               final isLoading = state is Loading;
//               return SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHeader(context),
//                       const SizedBox(height: 24),
//                       _buildProductNameField(),
//                       const SizedBox(height: 16),
//                       _buildPriceAndCostFields(),
//                       const SizedBox(height: 16),
//                       _buildStockField(),
//                       const SizedBox(height: 16),
//                       _buildDescriptionField(),
//                       const SizedBox(height: 16),
//                       _buildCategoriesSection(),
//                       const SizedBox(height: 24),
//                       _buildActions(context, isLoading),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Add new product',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Fill in the details to create a new product.',
//               style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductNameField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: const TextSpan(
//             text: 'Product name ',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//             children: [
//               TextSpan(
//                 text: '*',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _nameController,
//           decoration: _inputDecoration('e.g. Wireless Headphones'),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter a product name';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceAndCostFields() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               RichText(
//                 text: const TextSpan(
//                   text: 'Price (EGP) ',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: '*',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//                 ],
//                 decoration: _inputDecoration('0'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (double.tryParse(value) == null) return 'Invalid number';
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Cost (EGP)',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _costController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//                 ],
//                 decoration: _inputDecoration('0.00'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStockField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Stock quantity',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _stockController,
//           keyboardType: TextInputType.number,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           decoration: _inputDecoration('0'),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Description',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _descriptionController,
//           maxLines: 3,
//           decoration: _inputDecoration('Short product description...'),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoriesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.label_outline, size: 16, color: Colors.grey[600]),
//             const SizedBox(width: 4),
//             Text(
//               'Categories',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextFormField(decoration: _inputDecoration('Search categories...')),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Checkbox(
//               value: false,
//               onChanged: (value) {},
//               activeColor: const Color(0xFF5B4CF5),
//             ),
//             const Text('Test', style: TextStyle(fontSize: 14)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActions(BuildContext context, bool isLoading) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         TextButton(
//           onPressed: isLoading ? null : () => Navigator.of(context).pop(),
//           child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton(
//           onPressed: isLoading ? null : _handleSubmit,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF5B4CF5),
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             elevation: 0,
//           ),
//           child: isLoading
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//               : const Text('Add product'),
//         ),
//       ],
//     );
//   }

//   void _handleSubmit() {
//     if (_formKey.currentState!.validate()) {
//       // ✅ Calls the cubit using builder context — safe because BlocBuilder provides it
//       context.read<AddProductCubit>().createProduct(
//         name: _nameController.text,
//         description: _descriptionController.text,
//         price: _priceController.text,
//         stock: int.parse(
//           _stockController.text.isEmpty ? '0' : _stockController.text,
//         ),
//         cost: _costController.text,
//       );
//     }
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(color: Colors.grey[400]),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFF5B4CF5), width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//     );
//   }
// }
