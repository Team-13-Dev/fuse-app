import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_cubit.dart';
import 'package:fuse_system/features/categories/logic/cubit/categories_state.dart';

class AddCategoriesBlocListener extends StatelessWidget {
  final Widget child;
  const AddCategoriesBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        state.whenOrNull(
          createSuccess: (data) {
            // نجاح الإضافة
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Category created successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // ممكن تعمل refresh للقائمة بعد الإضافة
            context.read<CategoriesCubit>().fetchCategories();

            // أو ترجع للشاشة السابقة
            //  context.pop();
          },

          error: (error) {
            // في حالة الخطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.apiErrorModel.error),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },

      child: child,
    );
  }
}
