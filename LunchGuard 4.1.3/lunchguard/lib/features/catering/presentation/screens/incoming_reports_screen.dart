import 'package:flutter/material.dart';
import 'package:lunchguard/data/models/report_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/features/school/presentation/screens/report_detail_screen.dart';
import 'package:lunchguard/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class IncomingReportsScreen extends StatelessWidget {
  const IncomingReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cateringRepo = CateringRepository();
    final authRepo = context.read<AuthRepository>();
    final cateringId = authRepo.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<ReportModel>>(
        stream: cateringRepo.getIncomingReportsStream(cateringId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.drafts_outlined,
              message: 'Tidak ada laporan yang masuk.',
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
                  leading: const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange),
                  title: Text(report.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dari: ${report.schoolName}'),
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
    );
  }
}
