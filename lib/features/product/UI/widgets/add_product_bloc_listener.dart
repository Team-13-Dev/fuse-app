import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_cubit.dart';
import 'package:fuse_system/features/product/logic/cubit/add_product_state.dart';
import 'package:fuse_system/features/product/logic/cubit/product_cubit.dart';

class AddProductBlocListener extends StatelessWidget {
  final Widget child;

  const AddProductBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddProductCubit, AddProductState>(
      listenWhen: (previous, current) =>
          current is Loading || current is Success || current is Error,
      listener: (context, state) {
        state.maybeWhen(
          success: (data) {
            context.read<ProductCubit>().getProducts();
            context.pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          error: (error) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.apiErrorModel.error}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: child,
    );
  }
}
