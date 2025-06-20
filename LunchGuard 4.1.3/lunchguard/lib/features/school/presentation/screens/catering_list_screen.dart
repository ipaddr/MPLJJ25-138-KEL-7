import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/features/school/presentation/screens/catering_menu_screen.dart';
import 'package:lunchguard/features/school/presentation/widgets/catering_info_card.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';

class CateringListScreen extends StatefulWidget {
  const CateringListScreen({super.key});

  @override
  State<CateringListScreen> createState() => _CateringListScreenState();
}

class _CateringListScreenState extends State<CateringListScreen> {
  final SchoolRepository _schoolRepository = SchoolRepository();

  void _navigateToMenu(UserModel catering) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CateringMenuScreen(cateringId: catering.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<UserModel>>(
        stream: _schoolRepository.getCateringsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.storefront_outlined,
              message: 'Belum ada katering yang terdaftar.',
            );
          }

          final caterings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: caterings.length,
            itemBuilder: (context, index) {
              final catering = caterings[index];
              return CateringInfoCard(
                catering: catering,
                onTap: () => _navigateToMenu(catering),
              );
            },
          );
        },
      ),
    );
  }
}
