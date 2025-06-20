import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText = order.status.toUpperCase();
    IconData? statusIcon;

    switch (order.status) {
      case 'selesai':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'dibatalkan':
        chipColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'terkirim':
        chipColor = Colors.orange;
        statusIcon = Icons.local_shipping;
        break;
      default: // 'diproses'
        chipColor = Colors.blue;
        statusIcon = Icons.hourglass_top;
    }
    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 18),
      label: Text(statusText,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildStatusChip(context)),
                const SizedBox(height: 20),
                _buildDetailRow(
                    context, Icons.receipt_long, 'ID Pesanan:', order.id),
                const Divider(),
                _buildDetailRow(context, Icons.calendar_today, 'Tanggal:',
                    Formatters.formatDate(order.orderDate.toDate())),
                const Divider(),
                _buildDetailRow(
                    context, Icons.store, 'Katering:', order.cateringName),
                const Divider(),
                _buildDetailRow(
                    context, Icons.school, 'Sekolah:', order.schoolName),
                const Divider(),
                _buildDetailRow(context, Icons.restaurant_menu, 'Menu:',
                    "${order.quantity}x ${order.menuName}"),
                const Divider(),
                _buildDetailRow(context, Icons.price_check, 'Total Harga:',
                    Formatters.formatCurrency(order.totalPrice)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
