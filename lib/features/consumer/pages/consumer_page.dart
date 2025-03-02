import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_management_app/features/consumer/pages/consumer_dashboard.dart';
import 'package:food_management_app/features/user_auth/pages/notification_screen.dart';

class ConsumerPage extends StatelessWidget {
  const ConsumerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consumer"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        // actions: [
        //   // Add actions for the AppBar (Right-side icons)
        //   // IconButton(
        //   //   icon: Icon(Icons.notifications), // Notification Icon
        //   //   onPressed: () {
        //   //     Navigator.push(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //           builder: (context) =>
        //   //               NotificationScreen()), // Navigate to Notification Page
        //   //     );
        //   //   },
        //   // ),
        // ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Reduce brightness of background
              child: Image.asset(
                "assets/images/food_management.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  "assets/images/food_logo.jpg",
                  height: 100,
                ),
                const SizedBox(height: 30),

                // Buttons with styling
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsumerDashboard(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      const Text("Dashboard", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, "/request_food"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Request Food",
                      style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Sign Out", style: TextStyle(fontSize: 18)),
                ),
                IconButton(
                  icon: Icon(Icons.notifications), // Notification Icon
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NotificationScreen()), // Navigate to Notification Page
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
