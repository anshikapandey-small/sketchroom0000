import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserService {
  UserService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Live profile of the logged-in user (null until the document exists).
  Stream<UserProfile?> watchMe() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((s) => s.exists ? UserProfile.fromDoc(s) : null);
  }

  Future<UserProfile?> getMe() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final s = await _db.collection('users').doc(user.uid).get();
    return s.exists ? UserProfile.fromDoc(s) : null;
  }
}
