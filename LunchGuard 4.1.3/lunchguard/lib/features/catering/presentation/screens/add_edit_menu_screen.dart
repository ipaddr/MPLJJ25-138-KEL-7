// [HAPUS] Import ini tidak lagi diperlukan karena kodenya sudah universal
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lunchguard/core/utils/validators.dart';
import 'package:lunchguard/data/models/menu_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/shared/widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

class AddEditMenuScreen extends StatefulWidget {
  final MenuModel? menu;

  const AddEditMenuScreen({super.key, this.menu});

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  Uint8List? _imageBytes;
  String? _networkImageUrl;

  bool get isEditing => widget.menu != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.name ?? '');
    _priceController = TextEditingController(
        text: widget.menu?.price.toStringAsFixed(0) ?? '');
    _networkImageUrl = widget.menu?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final cateringRepo = CateringRepository();
      final authRepo = context.read<AuthRepository>();
      final cateringId = authRepo.currentUser!.uid;

      final menuData = MenuModel(
        id: widget.menu?.id ?? '',
        cateringId: cateringId,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        imageUrl: _networkImageUrl,
      );

      try {
        if (isEditing) {
          await cateringRepo.updateMenu(menuData, _imageBytes);
        } else {
          await cateringRepo.addMenu(menuData, _imageBytes);
        }
        if (mounted) {
          navigator.pop();
          navigator.pop();
        }
      } catch (e) {
        if (mounted) {
          navigator.pop();
          messenger
              .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Menu' : 'Tambah Menu Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (_imageBytes != null)
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : (_networkImageUrl != null &&
                                _networkImageUrl!.isNotEmpty)
                            ? Image.network(_networkImageUrl!,
                                fit: BoxFit.cover)
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt,
                                        size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                        'Ketuk untuk menambah gambar (Opsional)'),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Menu'),
                validator: (value) =>
                    Validators.validateNotEmpty(value, 'Nama Menu'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Harga', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    Validators.validateNotEmpty(value, 'Harga'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
