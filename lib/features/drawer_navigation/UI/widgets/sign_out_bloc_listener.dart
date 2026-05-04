import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/core/Routing/routes.dart';
import 'package:fuse_system/features/drawer_navigation/logic/cubit/signout_cubit.dart';
import 'package:fuse_system/features/drawer_navigation/logic/cubit/signout_state.dart';

class SignOutBlocListener extends StatelessWidget {
  final Widget child;
  const SignOutBlocListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignoutCubit, SignoutState>(
      listenWhen: (previous, current) =>
          current is Loading || current is Success || current is Error,
      listener: (context, state) {
        state.whenOrNull(
          loading: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          },

          success: () {
            // FIX #1: Dismiss the loading dialog before navigating.
            // rootNavigator: true ensures we pop the dialog, not a route
            // pushed by the drawer itself.
            Navigator.of(context, rootNavigator: true).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Sign Out Successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );

            context.pushNamedAndRemoveUntil(
              Routes.loginScreen,
              predicate: (route) => false,
            );
          },

          error: (error) {
            // Dismiss loading dialog
            Navigator.of(context, rootNavigator: true).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  error.apiErrorModel.error,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
