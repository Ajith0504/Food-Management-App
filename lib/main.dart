import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_management_app/features/consumer/pages/consumer_dashboard.dart';
import 'package:food_management_app/features/producer/pages/producer_dashboard.dart';
import 'package:food_management_app/features/producer/pages/producer_page.dart';
import 'package:food_management_app/features/producer/pages/upload_food_page.dart';
import 'package:food_management_app/features/user_auth/pages/home_page.dart';
import 'package:food_management_app/features/user_auth/pages/login_page.dart';
import 'package:food_management_app/features/user_auth/pages/role_selection_page.dart';
import 'package:food_management_app/features/user_auth/pages/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? FirebaseOptions(
            apiKey: "AIzaSyBFh1OSIzXrTdmm4H_fzQIa1mrF8H3clnc",
            appId: "1:554788460660:web:798e221c1950fef5f19921",
            messagingSenderId: "554788460660",
            projectId: "food-management-app-ff8df",
          )
        : null,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Project',
      initialRoute: '/login', // Default screen
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/role_selection': (context) => RoleSelectionPage(),
        '/producer_page': (context) => ProducerPage(),
        '/upload_food': (context) => UploadFoodPage(),
        '/producer_dashboard': (context) => ProducerDashboard(),
        '/consumer_dashboard': (context) => ConsumerDashboard(),
      },
    );
  }
}
