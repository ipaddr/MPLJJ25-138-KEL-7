import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/order_model.dart';

class SchoolActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onCancel;
  final VoidCallback? onReceived;

  const SchoolActiveOrderCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onReceived,
  });

  @override
  Widget build(BuildContext context) {
    bool isProcessing = order.status == 'diproses';
    bool isDelivered = order.status == 'terkirim';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(
                order.status.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: isProcessing ? Colors.blue : Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const Divider(height: 20),
            Text(
              "Pesanan ke: ${order.cateringName}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Menu: '),
                  TextSpan(
                    text: order.menuName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text('Jumlah: ${order.quantity} porsi'),
            const SizedBox(height: 4),
            Text(
              'Total: ${Formatters.formatCurrency(order.totalPrice)}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isProcessing)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Batalkan'),
                  ),
                if (isDelivered)
                  ElevatedButton(
                    onPressed: onReceived,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Konfirmasi Diterima'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
