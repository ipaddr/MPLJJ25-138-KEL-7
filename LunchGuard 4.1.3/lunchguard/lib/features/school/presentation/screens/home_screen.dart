import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/features/school/presentation/widgets/school_active_order_card.dart';
import 'package:lunchguard/shared/widgets/confirmation_dialog.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SchoolRepository _schoolRepository = SchoolRepository();

  void _updateOrderStatus(
      String orderId, String newStatus, String action) async {
    final confirm = await showConfirmationDialog(
      context,
      title: '$action Pesanan',
      content: 'Apakah Anda yakin ingin $action pesanan ini?',
    );

    if (confirm == true) {
      await _schoolRepository.updateOrderStatus(orderId, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final schoolId = authRepo.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<OrderModel>>(
        stream: _schoolRepository.getActiveOrdersForSchoolStream(schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.fastfood_outlined,
              message: 'Tidak ada pesanan aktif saat ini.\nAyo pesan sekarang!',
            );
          }
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return SchoolActiveOrderCard(
                order: order,
                onCancel: () =>
                    _updateOrderStatus(order.id, 'dibatalkan', 'membatalkan'),
                onReceived: () =>
                    _updateOrderStatus(order.id, 'selesai', 'menyelesaikan'),
              );
            },
          );
        },
      ),
    );
  }
}
