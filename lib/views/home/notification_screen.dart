import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/notification.dart';
import 'package:provider/provider.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      if (userViewModel.isLoggedIn) {
        userViewModel.fetchNotifications();
      } else {
        // Handle not logged in state (e.g., redirect to login screen)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          print(
              'Building NotificationScreen: ${userViewModel.notifications.length} notifications'); // Debug print

          if (userViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userViewModel.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: userViewModel.notifications.length,
            itemBuilder: (context, index) {
              final notification = userViewModel.notifications[index];
              print(
                  'Building notification tile: ${notification.id}'); // Debug print
              return NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () => _handleNotificationDismiss(notification.id),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(UserNotification notification) {
    print('Notification tapped: ${notification.id}'); // Debug print
    Provider.of<UserViewModel>(context, listen: false)
        .markNotificationAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case 'listing_approved':
      case 'listing_rejected':
        // Navigate to the listing detail page

        // TODO: Implement navigation to ListingDetailScreen

        print('TODO: Navigate to listing detail for ${notification.relatedId}');
        break;
      default:
        print('Unknown notification type: ${notification.type}');
    }
  }

  void _handleNotificationDismiss(String notificationId) {
    print('Notification dismissed: $notificationId'); // Debug print
    Provider.of<UserViewModel>(context, listen: false)
        .deleteNotification(notificationId);
  }
}

class NotificationTile extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Icon(_getIconForNotificationType(notification.type)),
        title: Text(notification.message),
        subtitle:
            Text(notification.createdAt.toString()), // Display creation time
        trailing: notification.isRead
            ? null
            : const Icon(Icons.fiber_new, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  IconData _getIconForNotificationType(String type) {
    switch (type) {
      case 'listing_approved':
        return Icons.check_circle;
      case 'listing_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }
}
