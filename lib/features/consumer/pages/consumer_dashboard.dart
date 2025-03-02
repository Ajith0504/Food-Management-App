import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  _ConsumerDashboardState createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    _initRequestsStream();
  }

  void _initRequestsStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _requestsStream = _firestore
          .collection("food_requests")
          .where("consumerId", isEqualTo: currentUser.uid)
          .orderBy("timestamp", descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Consumer Dashboard"),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text("User not logged in",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consumer Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initRequestsStream();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _requestsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading requests: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No food requests submitted yet.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];
              Map<String, dynamic> requestData =
                  request.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.fastfood,
                      size: 50, color: Colors.orange),
                  title: Text(
                      "Quantity Requested: ${requestData["quantityRequired"]} servings",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${requestData["status"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: requestData["status"] == "Pending"
                              ? Colors.orange
                              : requestData["status"] == "Matched"
                                  ? Colors.blue
                                  : Colors.green,
                        ),
                      ),
                      Text(
                        "Requested On: ${_formatTimestamp(requestData["timestamp"])}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  trailing: Column(
                    children: [
                      if (requestData["status"] == "Matched")
                        ElevatedButton(
                          onPressed: () =>
                              _acceptFood(request.id, requestData["producerId"]),
                          child: const Text("Accept"),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRequest(request.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Function to accept food and notify the producer
  void _acceptFood(String requestId, String producerId) async {
    try {
      // ✅ Update status in Firestore
      await _firestore.collection("food_requests").doc(requestId).update({
        "status": "Accepted",
      });

      // ✅ Fetch Producer's FCM Token
      DocumentSnapshot producerDoc =
          await _firestore.collection("users").doc(producerId).get();

      if (producerDoc.exists) {
        String? producerFcmToken = producerDoc.get("fcmToken");
        if (producerFcmToken != null) {
          await _sendNotificationToProducer(producerFcmToken);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food request accepted!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting request: $e")),
      );
    }
  }

  // ✅ Function to send notification to Producer
  Future<void> _sendNotificationToProducer(String producerFcmToken) async {
    const String serverKey =
        "YOUR_FIREBASE_SERVER_KEY"; // Replace with your actual server key

    var url = Uri.parse("https://fcm.googleapis.com/fcm/send");

    var payload = {
      "to": producerFcmToken,
      "notification": {
        "title": "Food Request Accepted",
        "body": "A consumer has accepted the food you uploaded!",
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode(payload),
      );

      print("FCM Response: ${response.body}");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // ✅ Function to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Date";
    DateTime date = timestamp.toDate();
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
  }

  // ✅ Function to delete request
  void _deleteRequest(String requestId) async {
    try {
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Delete"),
                content:
                    const Text("Are you sure you want to delete this request?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (confirmDelete) {
        await _firestore.collection("food_requests").doc(requestId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request deleted successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting request: $e")),
      );
    }
  }
}
