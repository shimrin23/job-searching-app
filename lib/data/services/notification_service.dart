import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<AppNotification> _notifications = [];
  bool _initialized = false;

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void initializeNotifications() {
    if (_initialized) return;

    _notifications = [
      AppNotification(
        id: '1',
        title: 'New Job Match!',
        message: 'Software Engineer position at Google matches your profile',
        type: NotificationType.jobAlert,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        jobId: 'job123',
      ),
      AppNotification(
        id: '2',
        title: '5 New Jobs Posted',
        message: 'Check out new opportunities in Software Development',
        type: NotificationType.newJob,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'Application Viewed',
        message:
            'Your application for Senior Developer was viewed by the employer',
        type: NotificationType.applicationUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Daily Recommendation',
        message: '10 new jobs matching your saved searches',
        type: NotificationType.recommendation,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '5',
        title: 'Profile Update',
        message: 'Complete your profile to get better job recommendations',
        type: NotificationType.system,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
    _initialized = true;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
