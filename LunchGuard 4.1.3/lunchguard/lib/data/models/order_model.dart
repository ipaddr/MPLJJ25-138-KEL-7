import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String? schoolPhotoUrl;
  final String cateringId;
  final String cateringName;
  final String menuName;
  final int quantity;
  final double totalPrice;
  final Timestamp orderDate;
  final String status; // 'diproses', 'terkirim', 'selesai', 'dibatalkan'

  OrderModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    this.schoolPhotoUrl,
    required this.cateringId,
    required this.cateringName,
    required this.menuName,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      schoolName: data['schoolName'] ?? '',
      schoolPhotoUrl: data['schoolPhotoUrl'],
      cateringId: data['cateringId'] ?? '',
      cateringName: data['cateringName'] ?? '',
      menuName: data['menuName'] ?? '',
      quantity: data['quantity'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      orderDate: data['orderDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'diproses',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolPhotoUrl': schoolPhotoUrl,
      'cateringId': cateringId,
      'cateringName': cateringName,
      'menuName': menuName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderDate': orderDate,
      'status': status,
    };
  }
}
