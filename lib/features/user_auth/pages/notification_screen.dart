import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_management_app/services/firebase_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('consumer_uid', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];

              return ListTile(
                title: Text("${notification['food_name']} is available"),
                subtitle: Text("Quantity: ${notification['quantity']}"),
                trailing: ElevatedButton(
                  child: Text("Accept"),
                  onPressed: () {
                    acceptFood(notification.id, notification['producer_uid']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void acceptFood(String notificationId, String producerUid) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({
      'status': 'accepted',
    });

    // sendPushNotification(producerUid, "Food Accepted", "Your food has been accepted by a consumer.");
    FirebaseNotificationService Notify = new FirebaseNotificationService();
    Notify.sendPushNotification(producerUid, "Food Accepted",
        "Your food has been accepted by a consumer.");
  }
}
