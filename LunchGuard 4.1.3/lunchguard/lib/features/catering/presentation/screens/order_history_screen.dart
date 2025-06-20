import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/shared/screens/order_detail_screen.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cateringRepo = CateringRepository();
    final authRepo = context.read<AuthRepository>();
    final cateringId = authRepo.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<OrderModel>>(
        stream: cateringRepo.getOrderHistoryStream(cateringId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
                message: 'Tidak ada riwayat pesanan.');
          }
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        order.status == 'selesai' ? Colors.green : Colors.red,
                    child: Icon(
                      order.status == 'selesai' ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(order.menuName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Dipesan oleh: ${order.schoolName}\n${Formatters.formatDate(order.orderDate.toDate())}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(order: order)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
