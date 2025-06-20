import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lunchguard/data/models/menu_model.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/features/school/presentation/widgets/order_card.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:lunchguard/shared/widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

class CateringMenuScreen extends StatefulWidget {
  final String cateringId;

  const CateringMenuScreen({super.key, required this.cateringId});

  @override
  State<CateringMenuScreen> createState() => _CateringMenuScreenState();
}

class _CateringMenuScreenState extends State<CateringMenuScreen> {
  final CateringRepository _cateringRepository = CateringRepository();
  final SchoolRepository _schoolRepository = SchoolRepository();

  Future<void> _showOrderDialog(
      MenuModel menu, UserModel schoolUser, UserModel cateringUser) async {
    final quantityController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pesan ${menu.name}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: quantityController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Jumlah Porsi'),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null ||
                    int.parse(value) < 1) {
                  return 'Masukkan jumlah yang valid';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final quantity = int.parse(quantityController.text);
                  final totalPrice = quantity * menu.price;

                  final newOrder = OrderModel(
                    id: '',
                    schoolId: schoolUser.uid,
                    schoolName: schoolUser.name,
                    schoolPhotoUrl: schoolUser.photoUrl,
                    cateringId: widget.cateringId,
                    cateringName: cateringUser.name,
                    menuName: menu.name,
                    quantity: quantity,
                    totalPrice: totalPrice,
                    orderDate: Timestamp.now(),
                    status: 'diproses',
                  );

                  navigator.pop();
                  showLoadingDialog(context);

                  try {
                    await _schoolRepository.createOrder(newOrder);
                    if (mounted) {
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Pesanan berhasil dibuat!'),
                            backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Gagal membuat pesanan: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Konfirmasi Pesanan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Katering')),
      body: FutureBuilder<List<UserModel?>>(
        future: Future.wait([
          authRepo.getUserDetails(authRepo.currentUser!.uid),
          authRepo.getUserDetails(widget.cateringId),
        ]),
        builder: (context, userDetailsSnapshot) {
          if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userDetailsSnapshot.hasData ||
              userDetailsSnapshot.data!.contains(null)) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }

          final schoolUser = userDetailsSnapshot.data![0]!;
          final cateringUser = userDetailsSnapshot.data![1]!;

          return StreamBuilder<List<MenuModel>>(
            stream: _cateringRepository.getMenusStream(widget.cateringId),
            builder: (context, menuSnapshot) {
              if (menuSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!menuSnapshot.hasData || menuSnapshot.data!.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.no_food,
                  message: 'Katering ini belum memiliki menu.',
                );
              }
              final menus = menuSnapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final menu = menus[index];
                  return OrderCard(
                    menu: menu,
                    onOrder: () =>
                        _showOrderDialog(menu, schoolUser, cateringUser),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
