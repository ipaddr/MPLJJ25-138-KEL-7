import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String cateringId;
  final String cateringName;
  final String orderId;
  final String title;
  final String description;
  final Timestamp reportDate;

  ReportModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.cateringId,
    required this.cateringName,
    required this.orderId,
    required this.title,
    required this.description,
    required this.reportDate,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      schoolName: data['schoolName'] ?? '',
      cateringId: data['cateringId'] ?? '',
      cateringName: data['cateringName'] ?? '',
      orderId: data['orderId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      reportDate: data['reportDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'schoolName': schoolName,
      'cateringId': cateringId,
      'cateringName': cateringName,
      'orderId': orderId,
      'title': title,
      'description': description,
      'reportDate': reportDate,
    };
  }
}
