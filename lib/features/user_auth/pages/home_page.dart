import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 77, 211, 57),
        elevation: 0, // Remove AppBar shadow
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.7, // Reduce brightness of background
              child: Image.asset(
                "assets/images/food_management.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Food Management App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Producer & Consumer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleButton(
                      context,
                      title: "Producer",
                      color: Colors.lightBlueAccent,
                      route: "/producer_page",
                    ),
                    const SizedBox(width: 30),
                    _buildRoleButton(
                      context,
                      title: "Consumer",
                      color: Colors.deepOrangeAccent,
                      route: "/consumer_page",
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign Out Button
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom button widget for Producer & Consumer
  Widget _buildRoleButton(BuildContext context,
      {required String title, required Color color, required String route}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, route);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(180, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Text(title),
    );
  }
}
