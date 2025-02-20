import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_management_app/features/consumer/pages/consumer_page.dart';
import 'package:food_management_app/features/consumer/pages/request_food.dart';
import 'package:food_management_app/utils/firestore_setup.dart';
import 'firebase_options.dart';
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
  await initFirebase();
  await createFirestoreCollections();
  runApp(const MyApp());
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/consumer_page': (context) => ConsumerPage(),
        '/request_food': (context) => RequestFood(),
        '/consumer_dashboard': (context) => ConsumerDashboard(),
      },
    );
  }
}
