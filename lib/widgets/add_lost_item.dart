import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/models/lost_Item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lost_and_found/noti_service.dart';
import 'package:lost_and_found/widgets/found_items.dart';
import 'package:lost_and_found/widgets/main_layout.dart';

class AddLostItem extends StatefulWidget {
  const AddLostItem({super.key});

  @override
  State<AddLostItem> createState() {
    return _LostItemsState();
  }
}

class _LostItemsState extends State<AddLostItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredItemName = "";
  var _enteredName = "";
  var _enteredEmail = "";
  var _enteredPhone = "";

  File? _selectedImage;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select an image!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      String? base64Image;
      try {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to read image!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final url = Uri.https(
          "lost-and-found-9b9cd-default-rtdb.europe-west1.firebasedatabase.app",
          "lost_items.json");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          'date': DateTime.now().toIso8601String(),
          'itemName': _enteredItemName,
          "itemImage": base64Image,
          'contactName': _enteredName,
          'contactEmail': _enteredEmail,
          'contactPhone': _enteredPhone,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            "Failed to save item. Status code: ${response.statusCode}");
      }

      Map<String, dynamic> response_data = json.decode(response.body);

      NotiService().showNotifications(
        title: 'Item Added',
        body: 'Your item has been added successfully!',
      );

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    }
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: "Item Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.length > 50) {
                        return "Incorrect Item Name!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredItemName = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          child: const Text('From Gallery'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickImageFromCamera,
                          child: const Text('From Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Me',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.length > 50) {
                        return "Incorrect Name!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return "Incorrect Email!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredEmail = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 8,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Mobile",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.length != 8) {
                        return "Incorrect Phone!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredPhone = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _saveItem();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Mark Item as Lost'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
