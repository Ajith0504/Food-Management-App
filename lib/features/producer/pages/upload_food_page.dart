import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadFoodPage extends StatefulWidget {
  @override
  _UploadFoodPageState createState() => _UploadFoodPageState();
}

class _UploadFoodPageState extends State<UploadFoodPage> {
  File? _selectedImage;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  String _foodType = "Eatable"; // Default selection

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      String userId = _auth.currentUser!.uid;
      String fileName =
          "food_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg";

      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(image);
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Image Upload Error: $e");
      return "";
    }
  }

  void _uploadFoodDetails() async {
    if (_selectedImage == null ||
        _quantityController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and upload an image")),
      );
      return;
    }

    String imageUrl = await _uploadImageToFirebase(_selectedImage!);
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
      return;
    }

    String producerId = _auth.currentUser!.uid;

    await _firestore.collection("food_uploads").add({
      "producerId": producerId,
      "foodType": _foodType,
      "quantity": _quantityController.text,
      "dateTimeCooked": _dateTimeController.text,
      "imageUrl": imageUrl,
      "status": "Available",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Food uploaded successfully!")),
    );

    Navigator.pop(context); // Return to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Food")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!,
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image,
                        size: 50, color: Colors.black54),
                  ),
            const SizedBox(height: 10),

            // Buttons for Camera & Gallery Selection
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
              decoration:
                  const InputDecoration(labelText: "Date & Time Cooked"),
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
                onPressed: _uploadFoodDetails, child: const Text("Submit")),
          ],
        ),
      ),
    );
  }
}
