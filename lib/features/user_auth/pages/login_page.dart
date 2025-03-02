import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_management_app/features/user_auth/firebase_auth/firebase_auth_services.dart';
import 'package:food_management_app/features/user_auth/pages/sign_up_page.dart';
import 'package:food_management_app/widgets/form_container_widget.dart';
import 'package:food_management_app/global/common/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSignin = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login to FMA'),
        backgroundColor: const Color.fromARGB(255, 80, 234, 93),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10.0,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 224, 72),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isSignin
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(
                    width: 5.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                          (route) => false);
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSignin = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() {
        _isSignin = false;
      });
      return;
    }

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      setState(() {
        _isSignin = false;
      });

      if (user != null) {
        // ✅ Store FCM Token in Firestore
        await _storeFCMToken(user.uid);

        showToast(message: "User is successfully signedIn");
        Navigator.pushNamed(context, "/home"); // Redirect to Home
      }
    } catch (e) {
      showToast(message: "Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() {
        _isSignin = false;
      });
    }
  }

  Future<void> _storeFCMToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // ✅ Get FCM Token
    String? token = await messaging.getToken();
    print("FCM Token: $token"); // Debugging

    if (token != null) {
      await firestore.collection("users").doc(userId).set({
        "fcmToken": token,
      }, SetOptions(merge: true)); // ✅ Merge instead of overwriting user data
    }
  }

  void _listenForTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update({
          "fcmToken": newToken,
        });
      }
    });
  }
}

// ajithcharan123@gmail.com
// 123456
// abc@gmail.com
