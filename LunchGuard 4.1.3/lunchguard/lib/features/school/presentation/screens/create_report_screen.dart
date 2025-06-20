import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/validators.dart';
import 'package:lunchguard/data/models/report_model.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/shared/widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  UserModel? _selectedCatering;
  final SchoolRepository _schoolRepository = SchoolRepository();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCatering == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Silakan pilih katering yang dilaporkan')),
        );
        return;
      }

      showLoadingDialog(context);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final authRepo = context.read<AuthRepository>();
      final schoolUser =
          await authRepo.getUserDetails(authRepo.currentUser!.uid);

      if (schoolUser == null) {
        if (mounted) {
          navigator.pop();
          messenger.showSnackBar(
            const SnackBar(content: Text('Gagal mendapatkan data pengguna')),
          );
        }
        return;
      }

      final report = ReportModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        cateringId: _selectedCatering!.uid,
        cateringName: _selectedCatering!.name,
        orderId: 'N/A',
        schoolId: schoolUser.uid,
        schoolName: schoolUser.name,
        reportDate: Timestamp.now(),
      );

      try {
        await _schoolRepository.createReport(report);
        if (mounted) {
          navigator.pop();
          navigator.pop();
          messenger.showSnackBar(
            const SnackBar(
                content: Text('Laporan berhasil dikirim!'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          navigator.pop();
          messenger.showSnackBar(
            SnackBar(content: Text('Gagal mengirim laporan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<List<UserModel>>(
                future: _schoolRepository.getCateringsStream().first,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final caterings = snapshot.data!;
                  return DropdownButtonFormField<UserModel>(
                    value: _selectedCatering,
                    decoration: const InputDecoration(
                        labelText: 'Katering yang Dilaporkan'),
                    items: caterings.map((catering) {
                      return DropdownMenuItem<UserModel>(
                        value: catering,
                        child: Text(catering.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCatering = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Pilih katering' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Laporan'),
                validator: (value) =>
                    Validators.validateNotEmpty(value, 'Judul Laporan'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Deskripsi Detail'),
                maxLines: 5,
                validator: (value) =>
                    Validators.validateNotEmpty(value, 'Deskripsi'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Kirim Laporan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
