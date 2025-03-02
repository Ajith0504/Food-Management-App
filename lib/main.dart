import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
import 'dart:js' as js;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await createFirestoreCollections();

  if (kIsWeb) {
    _registerServiceWorker(); // ✅ Register Service Worker for Web
  }

  _listenForTokenRefresh(); // ✅ Listen for FCM token updates

  setupFirebaseMessaging();


  runApp(const MyApp());
}

// ✅ Registers the Firebase Messaging service worker for Web
void _registerServiceWorker() {
  try {
    js.context.callMethod('importScripts', ["/firebase-messaging-sw.js"]);
  } catch (e) {
    print("Service Worker Registration Failed: $e");
  }
}

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      print("New Notification: ${notification.title} - ${notification.body}");
    }
  });
}


// ✅ Listens for Firebase Cloud Messaging token updates
Future<void> _listenForTokenRefresh() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications (iOS & Web)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("User denied notifications");
    return;
  }

  // Get the current FCM token
  String? token = await messaging.getToken();
  if (token != null) {
    await _updateUserToken(token);
  }

  // Listen for token updates
  messaging.onTokenRefresh.listen((newToken) async {
    await _updateUserToken(newToken);
  });

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// ✅ Handles background messages for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

// ✅ Updates the FCM token in Firestore for the logged-in user
Future<void> _updateUserToken(String token) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
      {"fcmToken": token},
      SetOptions(merge: true),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Project',
      initialRoute: '/login',
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
