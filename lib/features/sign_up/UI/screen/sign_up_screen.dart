import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuse_system/core/Helpers/extensions.dart';
import 'package:fuse_system/core/Routing/routes.dart';
import 'package:fuse_system/features/login/UI/screen/login_screen.dart';
import 'package:fuse_system/features/sign_up/UI/widgets/field_label_widget.dart';
import 'package:fuse_system/features/sign_up/UI/widgets/input_field_widget.dart';
import 'package:fuse_system/features/sign_up/UI/widgets/sign_up_bloc_listener.dart';
import 'package:fuse_system/features/sign_up/logic/cubit/signup_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    context.read<SignupCubit>().emailController = emailController;
    context.read<SignupCubit>().nameController = nameController;
    context.read<SignupCubit>().passwordController = passwordController;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Logo
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3DBF),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Image.asset(
                  'assets/Blue logo light.png',
                  width: 32.w,
                  height: 32.w,
                ),
              ),

              SizedBox(height: 12.h),

              // App name
              Text(
                'FUSE',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(
                      child: Text(
                        'Powering your e-commerce growth.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF9AA3B0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Full Name
                    FieldLabel(label: 'Full Name'),
                    SizedBox(height: 8.h),
                    InputField(
                      controller: nameController,
                      hintText: 'Enter your full name',
                      suffixIcon: Icons.person_outline,
                    ),

                    SizedBox(height: 18.h),

                    // Work Email
                    FieldLabel(label: 'Work Email'),
                    SizedBox(height: 8.h),
                    InputField(
                      controller: emailController,
                      hintText: 'name@company.com',
                      suffixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 18.h),

                    // Password
                    FieldLabel(label: 'Password'),
                    SizedBox(height: 8.h),
                    PasswordField(
                      controller: passwordController,
                      hintText: 'Create a password',
                      obscureText: _obscurePassword,
                      onToggle: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),

                    SizedBox(height: 28.h),

                    // Create Account Button
                    SignUpBlocListener(
                      child: SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<SignupCubit>().signup();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3DBF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Or continue with divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF9AA3B0),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB)),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google 'G' icon simulation
                                Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF4285F4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _SocialButton(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'X',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 22.h),

                    // Log In link
                    GestureDetector(
                      onTap: () => context.pushNamed(Routes.loginScreen),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            children: [
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A3DBF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Terms
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By creating an account, you agree to our ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF9AA3B0),
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9AA3B0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9AA3B0),
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9AA3B0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9AA3B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: child,
      ),
    );
  }
}
