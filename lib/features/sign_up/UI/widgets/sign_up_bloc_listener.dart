import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Routing/routes.dart';

import '../../../../core/Helpers/extensions.dart';
import '../../logic/cubit/signup_cubit.dart';
import '../../logic/cubit/signup_state.dart';

class SignUpBlocListener extends StatelessWidget {
  final Widget child;
  const SignUpBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listenWhen: (previous, current) =>
          current is Loading || current is Success || current is Error,
      listener: (context, state) {
        state.whenOrNull(
          loading: () {
            showDialog(
              context: context,
              builder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            );
          },
          success: (data) {
            context.pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Sign Up Successful")));
            context.pushNamedAndRemoveUntil(
              Routes.productScreen,
              predicate: (route) => false,
            );
          },
          error: (error) {
            context.pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.apiErrorModel.error)));
          },
        );
      },
      child: child,
    );
  }
}
