import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class ProducerDashboard extends StatefulWidget {
  const ProducerDashboard({super.key});

  @override
  _ProducerDashboardState createState() => _ProducerDashboardState();
}

class _ProducerDashboardState extends State<ProducerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    print(currentUser!.uid);

    String producerId = currentUser.uid; // ✅ Get Logged-in Producer's ID

    return Scaffold(
      appBar: AppBar(
        title: const Text("Producer Dashboard"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection("food_uploads")
            .where("producerId",
                isEqualTo: producerId) // ✅ Filter by logged-in user
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No food items uploaded yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var foodItem = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: foodItem["imageUrl"] != null
                      ? Image.memory(
                          foodItem["imageUrl"]
                              .bytes, // Properly cast List<dynamic> to List<int>
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_not_supported, size: 60),
                  title: Text("Food Type: ${foodItem["foodType"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quantity: ${foodItem["quantity"]} servings"),
                      Text("Cooked: ${foodItem["dateTimeCooked"]}"),
                      Text("Status: ${foodItem["status"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: foodItem["status"] == "Available"
                                  ? Colors.green
                                  : Colors.red)),
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
}
