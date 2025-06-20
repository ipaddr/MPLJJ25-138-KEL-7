import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/core/utils/formatters.dart';
import 'package:lunchguard/data/models/appeal_model.dart';
import 'package:lunchguard/data/models/report_model.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/data/repositories/catering_repository.dart';
import 'package:lunchguard/data/repositories/school_repository.dart';
import 'package:lunchguard/shared/widgets/appeal_bubble.dart';
import 'package:provider/provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final SchoolRepository _schoolRepo = SchoolRepository();
  final CateringRepository _cateringRepo = CateringRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(UserModel currentUser) async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();
    FocusScope.of(context).unfocus();

    final appeal = AppealModel(
      id: '',
      senderId: currentUser.uid,
      senderRole: currentUser.role!,
      text: messageText,
      timestamp: Timestamp.now(),
    );

    if (currentUser.role == AppConstants.schoolRole) {
      await _schoolRepo.addAppealToReport(widget.report.id, appeal);
    } else {
      await _cateringRepo.addAppealToReport(widget.report.id, appeal);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildDetailCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.report.title,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('ID Laporan: ${widget.report.id}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
                'Dilaporkan pada: ${Formatters.formatDate(widget.report.reportDate.toDate())}',
                style: Theme.of(context).textTheme.bodySmall),
            const Divider(height: 24),
            Text('Pelapor: ${widget.report.schoolName}'),
            const SizedBox(height: 4),
            Text('Katering Terlapor: ${widget.report.cateringName}'),
            const SizedBox(height: 16),
            const Text('Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.report.description,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(UserModel currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withAlpha(13),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Tulis balasan...',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(currentUser),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () => _sendMessage(currentUser),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final currentUser = authRepo.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Diskusi Laporan")),
      body: FutureBuilder<UserModel?>(
        future: authRepo.getUserDetails(currentUser.uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data!;
          return Column(
            children: [
              _buildDetailCard(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      color: Colors.grey.shade200,
                      child: StreamBuilder<List<AppealModel>>(
                        stream: _schoolRepo.getAppealsStream(widget.report.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text(
                                    "Belum ada diskusi untuk laporan ini."));
                          }

                          final appeals = snapshot.data!;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);
                            }
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: appeals.length,
                            itemBuilder: (context, index) {
                              final appeal = appeals[index];
                              return AppealBubble(
                                text: appeal.text,
                                isMe: appeal.senderId == currentUser.uid,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              _buildChatInput(user),
            ],
          );
        },
      ),
    );
  }
}
