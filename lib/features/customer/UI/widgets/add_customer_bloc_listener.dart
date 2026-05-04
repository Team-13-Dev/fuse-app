import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_cubit.dart';
import 'package:fuse_system/features/customer/logic/cubit/customer_state.dart';

class AddCustomerBlocListener extends StatelessWidget {
  final Widget child;
  const AddCustomerBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {
        state.maybeWhen(
          successCreate: (data) {
            context.read<CustomerCubit>().fetchCustomers();
            context.pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Customer added successfully!'),
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
