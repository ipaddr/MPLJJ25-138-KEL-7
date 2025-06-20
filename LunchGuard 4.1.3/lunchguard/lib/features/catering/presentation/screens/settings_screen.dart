import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
// [UBAH] Kita akan mengarahkan ke halaman edit profil yang sama
import 'package:lunchguard/features/school/presentation/screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    return Scaffold(
      // [UBAH] Seluruh body disamakan dengan halaman pengaturan sekolah
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(authRepo.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("Tidak dapat memuat data pengguna."));
          }
          final user = UserModel.fromFirestore(snapshot.data!);
          return ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName:
                    Text(user.name, style: const TextStyle(fontSize: 18)),
                accountEmail: Text(user.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 40.0))
                      : null,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profil'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Keluar'),
                onTap: () async {
                  await authRepo.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
