import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:fuse_system/core/DI/dependency_injection.dart';
import 'package:fuse_system/core/Helpers/shared_data_helper.dart';
import 'package:fuse_system/core/Networking/api_service.dart';
import 'package:fuse_system/core/Routing/routes.dart';

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  String _statusMessage = 'Initializing...';
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _statusMessage = 'Checking credentials...');

    final token = await SharedDataHelper.getSecuredString('token');

    if (token == null || token.isEmpty) {
      setState(() => _statusMessage = 'Redirecting to login...');
      Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
      return;
    }

    setState(() => _statusMessage = 'Validating session...');

    final isValid = await _validateToken();

    if (!mounted) return;

    if (isValid) {
      setState(() => _statusMessage = 'Welcome back!');
      Navigator.of(context).pushReplacementNamed(Routes.dashboardScreen);
    } else {
      setState(() => _statusMessage = 'Session expired...');
      await SharedDataHelper.deleteSecuredString('token');
      await SharedDataHelper.deleteSecuredString('businessId');
      await SharedDataHelper.deleteSecuredString('role');
      Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
    }
  }

  Future<bool> _validateToken() async {
    try {
      await getIt<ApiService>().getSegment().timeout(
        const Duration(seconds: 10),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _isChecked = false;
      _statusMessage = 'Retrying...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: OfflineBuilder(
        connectivityBuilder:
            (
              BuildContext context,
              List<ConnectivityResult> connectivity,
              Widget child,
            ) {
              final bool connected = !connectivity.contains(
                ConnectivityResult.none,
              );

              if (connected) {
                if (!_isChecked) {
                  _checkAuthentication();
                }
                return _buildOnlineUI();
              } else {
                return _buildNoInternetUI();
              }
            },
        child: const SizedBox(),
      ),
    );
  }

  Widget _buildNoInternetUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "No Internet Connection",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please check your connection and try again",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Image.asset("assets/no_internet.png"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _retry, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildOnlineUI() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B4FE8), Color(0xFF7B6FF0)],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4FE8).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/Blue logo light.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'FUSE',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Commerce Platform',
                style: TextStyle(color: Colors.grey[500]),
              ),

              const Spacer(),

              const CircularProgressIndicator(),

              const SizedBox(height: 20),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(_statusMessage, key: ValueKey(_statusMessage)),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
