import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_management_app/features/producer/pages/producer_dashboard.dart';
import 'package:food_management_app/features/user_auth/pages/notification_screen.dart';

class ProducerPage extends StatelessWidget {
  const ProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Green Shades
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✅ Main Content with Padding
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Top Bar with Notifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Producer",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ Dashboard & Upload Food Options (Grid Layout)
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2, // Two buttons per row
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                      children: [
                        _buildFeatureButton(
                          title: "Dashboard",
                          icon: Icons.dashboard,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProducerDashboard()),
                            );
                          },
                          bgColor: const Color(0xFFA5D6A7), // 🌿 Light Green
                          textColor: Colors.black,
                        ),
                        _buildFeatureButton(
                          title: "Upload Food",
                          icon: Icons.upload_file,
                          onTap: () {
                            Navigator.pushNamed(context, "/upload_food");
                          },
                          bgColor: const Color(0xFFFFCC80), // 🍊 Light Orange
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ✅ Floating Action Button for Sign Out
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, "/login");
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout),
      ),
    );
  }

  // ✅ Feature Button Widget
  Widget _buildFeatureButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color bgColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: textColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
