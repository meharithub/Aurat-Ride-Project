import 'dart:async';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';

class EnhancedNotificationsScreen extends StatefulWidget {
  const EnhancedNotificationsScreen({super.key});

  @override
  State<EnhancedNotificationsScreen> createState() => _EnhancedNotificationsScreenState();
}

class _EnhancedNotificationsScreenState extends State<EnhancedNotificationsScreen> {
  String? _userToken;
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _userToken = userData['token'];
    });
    
    if (_userToken != null) {
      await _loadNotifications();
      _startAutoRefresh();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getNotifications(_userToken!);
      
      if (response['success']) {
        setState(() {
          _notifications = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Notifications',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: Icon(Icons.mark_email_read, color: kPrimaryWhite),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] == true;
    final type = notification['type'] ?? 'general';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final createdAt = notification['created_at'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : kPrimaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[300]! : kPrimaryGreen.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: _buildNotificationIcon(type, isRead),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            color: isRead ? Colors.black87 : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _formatDateTime(createdAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () => _showNotificationOptions(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, bool isRead) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'ride_request':
        iconData = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'ride_completed':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = Colors.orange;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      case 'safety':
        iconData = Icons.security;
        iconColor = Colors.red;
        break;
      case 'system':
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read if not already read
    if (notification['is_read'] != true) {
      _markAsRead(notification['id'].toString());
    }

    // Handle notification action based on type
    final type = notification['type'] ?? 'general';
    switch (type) {
      case 'ride_request':
        // Navigate to ride details
        _navigateToRideDetails(notification);
        break;
      case 'ride_completed':
        // Navigate to ride history
        _navigateToRideHistory();
        break;
      case 'payment':
        // Navigate to payment screen
        _navigateToPayment();
        break;
      case 'promotion':
        // Navigate to offers screen
        _navigateToOffers();
        break;
      case 'safety':
        // Navigate to emergency screen
        _navigateToEmergency();
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationOptions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.mark_email_read),
              title: Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(notification['id'].toString());
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification['id'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final response = await ApiService.markNotificationRead(
        token: _userToken!,
        notificationId: notificationId,
      );

      if (response['success']) {
        // Update local state
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n['id'].toString() == notificationId,
          );
          if (index != -1) {
            _notifications[index]['is_read'] = true;
          }
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Mark all unread notifications as read
      for (final notification in _notifications) {
        if (notification['is_read'] != true) {
          await ApiService.markNotificationRead(
            token: _userToken!,
            notificationId: notification['id'].toString(),
          );
        }
      }

      // Update local state
      setState(() {
        for (final notification in _notifications) {
          notification['is_read'] = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    // In production, implement delete notification API
    setState(() {
      _notifications.removeWhere(
        (n) => n['id'].toString() == notificationId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification deleted')),
    );
  }

  void _navigateToRideDetails(Map<String, dynamic> notification) {
    // In production, navigate to specific ride details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to ride details')),
    );
  }

  void _navigateToRideHistory() {
    // In production, navigate to ride history
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to ride history')),
    );
  }

  void _navigateToPayment() {
    // In production, navigate to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to payment')),
    );
  }

  void _navigateToOffers() {
    // In production, navigate to offers screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to offers')),
    );
  }

  void _navigateToEmergency() {
    // In production, navigate to emergency screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to emergency')),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? 'Notification'),
        content: Text(notification['message'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
