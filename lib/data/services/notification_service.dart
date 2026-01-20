import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  List<AppNotification> _notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  bool _initialized = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void initializeNotifications() {
    if (_initialized) return;
    _initialized = true;
    _startListening();
  }

  void _startListening() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _notificationSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return AppNotification(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: NotificationType.values.firstWhere(
            (e) => e.toString() == 'NotificationType.${data['type']}',
            orElse: () => NotificationType.system,
          ),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
          jobId: data['jobId'],
          imageUrl: data['imageUrl'],
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    final unreadNotifications = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .delete();
  }

  // Create notification for specific user
  Future<void> sendNotificationToUser(
    String userId,
    String title,
    String message,
    NotificationType type, {
    String? jobId,
    String? imageUrl,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      if (jobId != null) 'jobId': jobId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  // Send notification to all users
  Future<void> sendNotificationToAll(
    String title,
    String message,
    NotificationType type, {
    String? jobId,
    String? imageUrl,
  }) async {
    final usersSnapshot = await _firestore.collection('users').get();
    final batch = _firestore.batch();

    for (var userDoc in usersSnapshot.docs) {
      final notificationRef = _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('notifications')
          .doc();

      batch.set(notificationRef, {
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        if (jobId != null) 'jobId': jobId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    }

    await batch.commit();
  }

  // Notify when job is saved
  Future<void> notifyJobSaved(String jobTitle) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await sendNotificationToUser(
      userId,
      'Job Saved',
      'You saved "$jobTitle" to your saved jobs',
      NotificationType.system,
    );
  }

  // Notify when job application is submitted
  Future<void> notifyJobApplied(String jobTitle, String? jobId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await sendNotificationToUser(
      userId,
      'Application Submitted',
      'Your application for "$jobTitle" has been submitted successfully',
      NotificationType.applicationUpdate,
      jobId: jobId,
    );
  }

  // Notify all users when new job is posted
  Future<void> notifyNewJobPosted(String jobTitle, String jobId) async {
    await sendNotificationToAll(
      'New Job Posted',
      'Check out the new opportunity: $jobTitle',
      NotificationType.newJob,
      jobId: jobId,
    );
  }

  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
