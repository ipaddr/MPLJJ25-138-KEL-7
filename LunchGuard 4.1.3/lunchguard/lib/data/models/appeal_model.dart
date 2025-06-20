import 'package:cloud_firestore/cloud_firestore.dart';

class AppealModel {
  final String id;
  final String senderId;
  final String senderRole; // 'school' atau 'catering'
  final String text;
  final Timestamp timestamp;

  AppealModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
  });

  factory AppealModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppealModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
