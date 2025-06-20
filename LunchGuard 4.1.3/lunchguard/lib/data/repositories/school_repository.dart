import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/data/models/appeal_model.dart';
import 'package:lunchguard/data/models/user_model.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/models/report_model.dart';

class SchoolRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getCateringsStream() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.cateringRole)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> createOrder(OrderModel order) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .add(order.toMap());
  }

  Stream<List<OrderModel>> getActiveOrdersForSchoolStream(String schoolId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('schoolId', isEqualTo: schoolId)
        .where('status', whereIn: ['diproses', 'terkirim'])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<OrderModel>> getOrderHistoryStream(String schoolId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('schoolId', isEqualTo: schoolId)
        .where('status', whereIn: ['selesai', 'dibatalkan'])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> createReport(ReportModel report) async {
    await _firestore
        .collection(AppConstants.reportsCollection)
        .add(report.toMap());
  }

  Stream<List<ReportModel>> getReportHistoryStream(String schoolId) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': newStatus});
  }

  Stream<List<AppealModel>> getAppealsStream(String reportId) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .collection('appeals')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppealModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addAppealToReport(String reportId, AppealModel appeal) async {
    await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .collection('appeals')
        .add(appeal.toMap());
  }
}
