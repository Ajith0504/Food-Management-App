import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _acceptFood(String foodId, String producerId) async {
    String consumerId = _auth.currentUser!.uid;

    // Update food status & add accepted consumerId
    await _firestore.collection("food_uploads").doc(foodId).update({
      "status": "Accepted",
      "acceptedBy": consumerId,
    });

    // Notify Producer
    await _firestore.collection("notifications").add({
      "producerId": producerId,
      "message": "Your food item has been accepted by a consumer!",
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Food accepted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Food")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("food_uploads")
            .where("status", isEqualTo: "Available") // Only available food
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No food available."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var foodItem = snapshot.data!.docs[index];
              String foodId = foodItem.id;
              String producerId = foodItem["producerId"];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ListTile(
                  title: Text("Food Type: ${foodItem["foodType"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quantity: ${foodItem["quantity"]} servings"),
                      Text("Cooked on: ${foodItem["dateTimeCooked"]}"),
                      Text("Status: ${foodItem["status"]}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _acceptFood(foodId, producerId),
                    child: const Text("Accept"),
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
