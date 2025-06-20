import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/data/models/appeal_model.dart';
import 'package:lunchguard/data/models/menu_model.dart';
import 'package:lunchguard/data/models/order_model.dart';
import 'package:lunchguard/data/models/report_model.dart';

class CateringRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<MenuModel>> getMenusStream(String cateringId) {
    return _firestore
        .collection(AppConstants.menusCollection)
        .where('cateringId', isEqualTo: cateringId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MenuModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addMenu(MenuModel menu, Uint8List? imageBytes) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await _uploadImage(menu.cateringId, imageBytes);
    }

    Map<String, dynamic> menuData = menu.toMap();
    menuData['imageUrl'] = imageUrl;

    await _firestore.collection(AppConstants.menusCollection).add(menuData);
  }

  Future<void> updateMenu(MenuModel menu, Uint8List? imageBytes) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await _uploadImage(menu.cateringId, imageBytes);
    }

    Map<String, dynamic> menuData = menu.toMap();
    if (imageUrl != null) {
      menuData['imageUrl'] = imageUrl;
    }

    await _firestore
        .collection(AppConstants.menusCollection)
        .doc(menu.id)
        .update(menuData);
  }

  Future<String> _uploadImage(String cateringId, Uint8List imageBytes) async {
    String fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref =
        _storage.ref().child('menu_images').child(cateringId).child(fileName);
    UploadTask uploadTask = ref.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteMenu(String menuId) async {
    await _firestore
        .collection(AppConstants.menusCollection)
        .doc(menuId)
        .delete();
  }

  Stream<List<OrderModel>> getActiveOrdersStream(String cateringId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('cateringId', isEqualTo: cateringId)
        .where('status', whereIn: ['diproses', 'terkirim'])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<OrderModel>> getOrderHistoryStream(String cateringId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('cateringId', isEqualTo: cateringId)
        .where('status', whereIn: ['selesai', 'dibatalkan'])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': newStatus});
  }

  Stream<List<ReportModel>> getIncomingReportsStream(String cateringId) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('cateringId', isEqualTo: cateringId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addAppealToReport(String reportId, AppealModel appeal) async {
    await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .collection('appeals')
        .add(appeal.toMap());
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
}
