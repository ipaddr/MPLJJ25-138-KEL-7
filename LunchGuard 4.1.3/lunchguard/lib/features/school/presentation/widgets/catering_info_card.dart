import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/user_model.dart';

class CateringInfoCard extends StatelessWidget {
  final UserModel catering;
  final VoidCallback onTap;

  const CateringInfoCard({
    super.key,
    required this.catering,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    catering.photoUrl != null && catering.photoUrl!.isNotEmpty
                        ? NetworkImage(catering.photoUrl!)
                        : null,
                child: catering.photoUrl == null || catering.photoUrl!.isEmpty
                    ? const Icon(Icons.storefront, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catering.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat Menu',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
