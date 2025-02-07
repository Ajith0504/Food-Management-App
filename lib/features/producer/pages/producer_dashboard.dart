import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProducerDashboard extends StatelessWidget {
  const ProducerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final String producerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Producer Dashboard"), backgroundColor: Colors.blue),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("food_uploads")
            .where("producerId", isEqualTo: producerId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var foodList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: foodList.length,
            itemBuilder: (context, index) {
              var food = foodList[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(food["imageUrl"], width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(food["foodName"]),
                  subtitle: Text("Quantity: ${food["quantity"]}, Status: ${food["status"]}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
