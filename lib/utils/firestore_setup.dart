import 'package:cloud_firestore/cloud_firestore.dart';
// import './../firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';


Future<void> createFirestoreCollections() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection("food_uploads").doc('example_request').set({
    "producerId": "123abc",
    "foodType": "Eatable",
    "quantity": 10,
    "dateTimeCooked": "2024-02-10 12:00",
    "imageUrl": "https://hips.hearstapps.com/hmg-prod/images/fresh-ripe-watermelon-slices-on-wooden-table-royalty-free-image-1684966820.jpg?crop=0.6673xw:1xh;center,top&resize=1200:*",
    "status": "Available",
  });

  await firestore.collection("food_requests").doc("example_request").set({
    "consumerId": "456xyz",
    "quantityRequired": 8,
    "status": "Pending",
  });
}
