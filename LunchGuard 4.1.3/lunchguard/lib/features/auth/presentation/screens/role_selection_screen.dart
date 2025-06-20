import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/shared/widgets/loading_dialog.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    showLoadingDialog(context);
    final authRepo = context.read<AuthRepository>();
    final user = authRepo.currentUser;

    if (user != null) {
      try {
        await authRepo.updateUserRole(user.uid, role);
        if (context.mounted) {
          Navigator.of(context).pop(); // close dialog
          // Arahkan ke dashboard yang sesuai
          if (role == AppConstants.schoolRole) {
            context.go('/school_dashboard');
          } else {
            context.go('/catering_dashboard');
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memilih peran: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.group_add_outlined,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Satu Langkah Lagi!',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih peran Anda di dalam aplikasi LunchGuard.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.school_outlined),
                label: const Text('Saya Pihak Sekolah'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _selectRole(context, AppConstants.schoolRole),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Saya Penyedia Katering'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                onPressed: () =>
                    _selectRole(context, AppConstants.cateringRole),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
