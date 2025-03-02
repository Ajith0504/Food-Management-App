import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadFoodPage extends StatefulWidget {
  const UploadFoodPage({super.key});

  @override
  _UploadFoodPageState createState() => _UploadFoodPageState();
}

class _UploadFoodPageState extends State<UploadFoodPage> {
  File? _selectedImage;
  Uint8List? _webImage;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  String _foodType = "Eatable";
  bool _isUploading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() => _webImage = bytes);
    } catch (e) {
      print("Image selection error: $e");
    }
  }

  Future<void> _uploadFoodDetails() async {
    if (_webImage == null || _quantityController.text.isEmpty || _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and upload an image")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String producerId = _auth.currentUser!.uid;

      await _firestore.collection("food_uploads").add({
        "producerId": producerId,
        "foodType": _foodType,
        "quantity": int.parse(_quantityController.text),
        "dateTimeCooked": _dateTimeController.text,
        "imageBlob": _webImage, // Storing image in blob format
        "status": "Available",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food uploaded successfully!")),
      );

      // Notify consumers about the available food
      _notifyConsumers(int.parse(_quantityController.text), producerId);

      setState(() {
        _webImage = null;
        _quantityController.clear();
        _dateTimeController.clear();
        _isUploading = false;
      });
    } catch (e) {
      print("Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

      setState(() => _isUploading = false);
    }
  }

  Future<void> _notifyConsumers(int availableQuantity, String producerId) async {
    // Fetch all consumer requests that match the available quantity
    QuerySnapshot consumerRequests = await _firestore
        .collection("food_requests")
        .where("status", isEqualTo: "Pending")
        .get();

    List<String> matchedConsumerTokens = [];

    for (var doc in consumerRequests.docs) {
      var data = doc.data() as Map<String, dynamic>;
      int requiredQuantity = data["quantityRequired"];
      String consumerId = data["consumerId"];

      if (requiredQuantity <= availableQuantity) {
        // Get the consumer's FCM token
        DocumentSnapshot consumerDoc = await _firestore.collection("users").doc(consumerId).get();
        if (consumerDoc.exists) {
          String? token = consumerDoc["fcmToken"];
          if (token != null) {
            matchedConsumerTokens.add(token);
          }
        }

        // Update the request status to "Matched"
        await _firestore.collection("food_requests").doc(doc.id).update({"status": "Matched"});
      }
    }

    // Send push notification to matched consumers
    for (String token in matchedConsumerTokens) {
      await _sendPushNotification(token, "Food Available!", "A food donation matching your request is available.");
    }
  }

  Future<void> _sendPushNotification(String token, String title, String body) async {
    const String serverKey = "YOUR_FIREBASE_SERVER_KEY";

    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode({
          "to": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          }
        }),
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Food")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _webImage != null
                ? Image.memory(_webImage!,
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.black54),
                  ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _foodType,
              items: ["Eatable", "Non-Eatable"].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _foodType = value!),
              decoration: const InputDecoration(labelText: "Food Type"),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _dateTimeController,
              decoration: const InputDecoration(labelText: "Date & Time Cooked"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _dateTimeController.text =
                          DateFormat('yyyy-MM-dd HH:mm').format(DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      ));
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFoodDetails,
              child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
