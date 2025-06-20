import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String cateringId;
  final String name;
  final double price;
  final String? imageUrl;

  MenuModel({
    required this.id,
    required this.cateringId,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      cateringId: data['cateringId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cateringId': cateringId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
