import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadFoodPage extends StatefulWidget {
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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      // if (kIsWeb) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      // } else {
        setState(() => _selectedImage = File(pickedFile.path));
      // }
    } catch (e) {
      print("Image selection error: $e");
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_selectedImage == null && _webImage == null) return "";

    try {
      String userId = _auth.currentUser!.uid;
      String fileName =
          "food_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(_webImage!);
      } else {
        uploadTask = ref.putFile(_selectedImage!);
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image Upload Error: $e");
      return "";
    }
  }

  void _uploadFoodDetails() async {
    if ((_selectedImage == null && _webImage == null) ||
        _quantityController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and upload an image")),
      );
      return;
    }

    setState(() => _isUploading = true); // Start Loading Indicator

    try {
      // String imageUrl = await _uploadImageToFirebase();
      // if (imageUrl.isEmpty) {
      //   throw "Failed to upload image";
      // }

      String producerId = _auth.currentUser!.uid;

      await _firestore.collection("food_uploads").add({
        "producerId": producerId,
        "foodType": _foodType,
        "quantity": _quantityController.text,
        "dateTimeCooked": _dateTimeController.text,
        "imageUrl": Blob(_webImage!),
        "status": "Available",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food uploaded successfully!")),
      );

      // ✅ Reset fields for a new submission
      setState(() {
        _selectedImage = null;
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

      setState(() => _isUploading = false); // ✅ Stop Loading Indicator
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
                : _selectedImage != null
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
              onPressed: _isUploading ? null : _uploadFoodDetails,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
