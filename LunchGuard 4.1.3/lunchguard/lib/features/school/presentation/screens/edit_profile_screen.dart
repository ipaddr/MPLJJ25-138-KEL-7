// [HAPUS] Import ini tidak lagi diperlukan
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/user_repository.dart';
import 'package:lunchguard/shared/widgets/loading_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      _imageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      try {
        await _userRepository.updateUserProfile(
          widget.user.uid,
          _nameController.text.trim(),
          _imageBytes,
        );

        if (mounted) {
          navigator.pop();
          navigator.pop();
          messenger.showSnackBar(
            const SnackBar(
                content: Text('Profil berhasil diperbarui!'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          navigator.pop();
          messenger.showSnackBar(
            SnackBar(content: Text('Gagal memperbarui profil: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (_imageBytes != null)
                        ? MemoryImage(_imageBytes!)
                        : (widget.user.photoUrl != null &&
                                widget.user.photoUrl!.isNotEmpty)
                            ? NetworkImage(widget.user.photoUrl!)
                            : null as ImageProvider?,
                    child: (_imageBytes == null &&
                            (widget.user.photoUrl == null ||
                                widget.user.photoUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Username tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.email,
                decoration:
                    const InputDecoration(labelText: 'Email', filled: true),
                readOnly: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
