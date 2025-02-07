import 'package:flutter/material.dart';
import 'package:food_management_app/features/producer/pages/producer_dashboard.dart';
import 'package:food_management_app/features/producer/pages/upload_food_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProducerPage extends StatelessWidget {
  const ProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Producer"), backgroundColor: Colors.blue),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProducerDashboard())),
              child: const Text("Dashboard"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/upload_food"),
              child: const Text("Upload Food"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
