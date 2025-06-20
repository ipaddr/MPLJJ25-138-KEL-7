import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/menu_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/features/catering/presentation/screens/add_edit_menu_screen.dart';
import 'package:lunchguard/features/catering/presentation/widgets/menu_item_card.dart';
import 'package:lunchguard/shared/widgets/confirmation_dialog.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final CateringRepository _cateringRepository = CateringRepository();

  void _navigateToAddEditScreen([MenuModel? menu]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMenuScreen(menu: menu),
      ),
    );
  }

  void _deleteMenu(String menuId) async {
    final confirm = await showConfirmationDialog(
      context,
      title: 'Hapus Menu',
      content:
          'Apakah Anda yakin ingin menghapus menu ini? Tindakan ini tidak dapat diurungkan.',
    );

    if (confirm == true) {
      try {
        await _cateringRepository.deleteMenu(menuId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus menu: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final cateringId = authRepo.currentUser?.uid;

    if (cateringId == null) {
      return const Center(child: Text('Error: User tidak ditemukan.'));
    }

    return Scaffold(
      body: StreamBuilder<List<MenuModel>>(
        stream: _cateringRepository.getMenusStream(cateringId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.menu_book,
              message:
                  'Anda belum memiliki menu.\nKetuk tombol + untuk menambah menu baru.',
            );
          }

          final menus = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return MenuItemCard(
                menu: menu,
                onEdit: () => _navigateToAddEditScreen(menu),
                onDelete: () => _deleteMenu(menu.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: 'Tambah Menu',
        // [FIX] Argumen 'child' dipindahkan ke akhir
        child: const Icon(Icons.add),
      ),
    );
  }
}
