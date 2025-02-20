import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  _ConsumerDashboardState createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    String consumerId = currentUser.uid; // ✅ Get Logged-in Consumer's ID

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consumer Dashboard"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("food_requests")
            .where("consumerId",
                isEqualTo: consumerId) // ✅ Filter logged-in user
            .orderBy("timestamp", descending: true) // ✅ Sort by newest first
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No food requests submitted yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];

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
                      "Quantity Requested: ${request["quantityRequired"]} servings"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${request["status"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: request["status"] == "Pending"
                              ? Colors.orange
                              : request["status"] == "Matched"
                                  ? Colors.blue
                                  : Colors.green,
                        ),
                      ),
                      Text(
                        "Requested On: ${_formatTimestamp(request["timestamp"])}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Date";
    DateTime date = timestamp.toDate();
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
  }
}
