import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/menu_model.dart';

class OrderCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onOrder;

  const OrderCard({
    super.key,
    required this.menu,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: menu.imageUrl != null && menu.imageUrl!.isNotEmpty
                ? Image.network(
                    menu.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant,
                        size: 50, color: Colors.grey),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(menu.price),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onOrder,
                      icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                      label: const Text('Pesan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
