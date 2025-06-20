import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/report_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/features/school/presentation/screens/create_report_screen.dart';
import 'package:lunchguard/features/school/presentation/screens/report_detail_screen.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolRepo = SchoolRepository();
    final authRepo = context.read<AuthRepository>();
    final schoolId = authRepo.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<ReportModel>>(
        stream: schoolRepo.getReportHistoryStream(schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.file_copy_outlined,
              message: 'Anda belum membuat laporan.',
            );
          }
          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading:
                      const Icon(Icons.receipt_long, color: Colors.blueGrey),
                  title: Text(report.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Untuk: ${report.cateringName}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportDetailScreen(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportScreen()),
          );
        },
        tooltip: 'Buat Laporan Baru',
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
