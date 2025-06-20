import 'package:flutter/material.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Text(report.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Dari: ${report.schoolName}\nPada: ${Formatters.formatDate(report.reportDate.toDate())}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigasi ke halaman detail laporan
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(report.title),
              content: SingleChildScrollView(child: Text(report.description)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Tutup")),
              ],
            ),
          );
        },
      ),
    );
  }
}
