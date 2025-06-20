import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/features/catering/presentation/widgets/active_order_card.dart';
import 'package:lunchguard/shared/widgets/confirmation_dialog.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CateringRepository _cateringRepository = CateringRepository();

  void _updateOrderStatus(
      String orderId, String newStatus, String action) async {
    final confirm = await showConfirmationDialog(
      context,
      title: '$action Pesanan',
      content: 'Apakah Anda yakin ingin $action pesanan ini?',
    );

    if (confirm == true) {
      await _cateringRepository.updateOrderStatus(orderId, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final cateringId = authRepo.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<OrderModel>>(
        stream: _cateringRepository.getActiveOrdersStream(cateringId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              message: 'Tidak ada pesanan aktif.',
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ActiveOrderCard(
                order: order,
                onCancel: () =>
                    _updateOrderStatus(order.id, 'dibatalkan', 'membatalkan'),
                onSend: () => _updateOrderStatus(
                    order.id, 'terkirim', 'mengirim pesanan'),
              );
            },
          );
        },
      ),
    );
  }
}
