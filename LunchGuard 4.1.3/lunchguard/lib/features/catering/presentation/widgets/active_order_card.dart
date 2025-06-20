import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/order_model.dart';

class ActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const ActiveOrderCard({
    super.key,
    required this.order,
    required this.onCancel,
    required this.onSend,
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
            ),
            const Divider(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: order.schoolPhotoUrl != null &&
                          order.schoolPhotoUrl!.isNotEmpty
                      ? NetworkImage(order.schoolPhotoUrl!)
                      : null,
                  child: order.schoolPhotoUrl == null ||
                          order.schoolPhotoUrl!.isEmpty
                      ? const Icon(Icons.school, size: 30, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.schoolName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Dipesan: ${Formatters.formatDate(order.orderDate.toDate())}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Pesanan: '),
                  TextSpan(
                    text: "${order.quantity}x ${order.menuName}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Batalkan'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSend,
                    child: const Text('Kirim Pesanan'),
                  ),
                ],
              )
            else if (isDelivered)
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Menunggu konfirmasi dari sekolah...',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
