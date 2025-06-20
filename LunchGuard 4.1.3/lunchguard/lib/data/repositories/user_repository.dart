import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lunchguard/core/constants/app_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateUserProfile(
      String uid, String newName, Uint8List? imageBytes) async {
    final Map<String, dynamic> dataToUpdate = {
      'name': newName,
    };

    if (imageBytes != null) {
      final photoUrl = await _uploadProfileImage(uid, imageBytes);
      dataToUpdate['photoUrl'] = photoUrl;
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(dataToUpdate);
  }

  Future<String> _uploadProfileImage(String uid, Uint8List imageBytes) async {
    String fileName = 'profile_$uid.jpg';
    Reference ref = _storage.ref().child('profile_images').child(fileName);
    UploadTask uploadTask = ref.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
