import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_management_app/features/consumer/pages/consumer_dashboard.dart';
import 'package:food_management_app/features/user_auth/pages/food_list_page.dart';
import 'package:food_management_app/features/user_auth/pages/notification_screen.dart';

class ConsumerPage extends StatelessWidget {
  const ConsumerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF2E7D32)], // Green Shades
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✅ Content with Padding
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
                      Text(
                        "Consumer",
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

                  // ✅ Food List Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoodListPage()),
                      );
                    },
                    child: _buildFeatureCard(
                      title: "Available Food Near You",
                      subtitle: "Tap to view food items",
                      icon: Icons.fastfood_rounded,
                      bgColor: Colors.white,
                      iconColor: Colors.green[700],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Dashboard & Request Buttons (Now in Grid Layout)
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
                                      const ConsumerDashboard()),
                            );
                          },
                          bgColor: const Color(0xFFA5D6A7), // 🌿 Light Green
                          textColor: Colors.black,
                        ),
                        _buildFeatureButton(
                          title: "Request Food",
                          icon: Icons.food_bank,
                          onTap: () {
                            Navigator.pushNamed(context, "/request_food");
                          },
                          bgColor: const Color(0xFFFFCC80), // 🍊 Light Orange
                          textColor: Colors.black,
                        ),
                        // _buildFeatureButton(
                        //   title: "Sign Out",
                        //   icon: Icons.logout,
                        //   onTap: () {
                        //     FirebaseAuth.instance.signOut();
                        //     Navigator.pushReplacementNamed(context, "/login");
                        //   },
                        //   bgColor: Colors.red,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, "/login");
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.logout),
      ),
    );
  }

  // ✅ Feature Card for "View Available Food"
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          // Right Side Icon
          Icon(icon, size: 40, color: iconColor),
        ],
      ),
    );
  }

  // ✅ Feature Buttons for Dashboard, Request Food, and Sign Out
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
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
