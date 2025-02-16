import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDemo extends StatefulWidget {
  @override
  _FirestoreDemoState createState() => _FirestoreDemoState();
}

class _FirestoreDemoState extends State<FirestoreDemo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to insert user records into Firestore
  Future<void> insertUsers() async {
    CollectionReference users = _firestore.collection('users');

    List<Map<String, dynamic>> userList = [
      {"name": "Alice", "age": 25, "email": "alice@example.com"},
      {"name": "Bob", "age": 30, "email": "bob@example.com"},
      {"name": "Charlie", "age": 22, "email": "charlie@example.com"},
    ];

    for (var user in userList) {
      await users.add(user);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Users added successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firestore User Insertion")),
      body: Center(
        child: ElevatedButton(
          onPressed: insertUsers,
          child: Text("Insert Users"),
        ),
      ),
    );
  }
}
