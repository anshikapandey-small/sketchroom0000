import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/group.dart';

class GroupException implements Exception {
  GroupException(this.message);
  final String message;
}

/// Groups live in `groups/{id}`. Join codes live in `joinCodes/{CODE}`
/// (so students can look a code up without being able to list all groups).
class GroupService {
  GroupService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Groups the current user belongs to (as student or teacher).
  Stream<List<Group>> watchMyGroups() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(<Group>[]);
    return _db
        .collection('groups')
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Group.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Teachers only (enforced by Firestore rules too). Returns the join code.
  Future<String> createGroup(String name) async {
    final user = _auth.currentUser!;
    final profile = await _db.collection('users').doc(user.uid).get();
    final teacherName =
        (profile.data()?['name'] as String?) ?? user.displayName ?? 'Teacher';

    String? code;
    for (var i = 0; i < 8; i++) {
      final candidate = _randomCode();
      final taken = await _db.collection('joinCodes').doc(candidate).get();
      if (!taken.exists) {
        code = candidate;
        break;
      }
    }
    if (code == null) {
      throw GroupException('Could not create a join code. Please try again.');
    }

    final groupRef = _db.collection('groups').doc();
    final batch = _db.batch();
    batch.set(groupRef, {
      'name': name,
      'teacherId': user.uid,
      'teacherName': teacherName,
      'joinCode': code,
      'memberIds': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('joinCodes').doc(code), {'groupId': groupRef.id});
    await batch.commit();
    return code;
  }

  Future<void> joinGroup(String rawCode) async {
    final uid = _auth.currentUser!.uid;
    final code = rawCode.trim().toUpperCase();

    final codeSnap = await _db.collection('joinCodes').doc(code).get();
    if (!codeSnap.exists) {
      throw GroupException('No group found with that code. Check it and try again.');
    }
    final groupId = codeSnap.data()!['groupId'] as String;

    final mine = await _db
        .collection('groups')
        .where('memberIds', arrayContains: uid)
        .get();
    if (mine.docs.any((d) => d.id == groupId)) {
      throw GroupException("You're already in this group.");
    }

    await _db.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  static String friendlyError(Object e) {
    if (e is GroupException) return e.message;
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'You do not have permission to do that.';
      }
      if (e.code == 'unavailable') {
        return 'No internet connection. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
