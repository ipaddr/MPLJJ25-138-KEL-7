import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Penundaan untuk estetika, agar splash screen tidak hilang terlalu cepat
    await Future.delayed(const Duration(seconds: 2));

    // Periksa apakah widget masih ada di tree sebelum navigasi
    if (!mounted) return;

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final user = authRepo.currentUser;

    if (user == null) {
      context.go('/login');
    } else {
      final userDetails = await authRepo.getUserDetails(user.uid);
      if (mounted) {
        // Periksa lagi sebelum navigasi
        if (userDetails?.role == AppConstants.schoolRole) {
          context.go('/school_dashboard');
        } else if (userDetails?.role == AppConstants.cateringRole) {
          context.go('/catering_dashboard');
        } else {
          // Jika role null (misal: user baru daftar tapi belum pilih role)
          context.go('/role_selection');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2196F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.food_bank, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'LunchGuard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
