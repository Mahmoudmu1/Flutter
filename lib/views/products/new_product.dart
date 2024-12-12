// New Product Screen: Insert new product details
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: showSelectionDialog,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey),
                  ),
                  height: 200,
                  child: _image == null
                      ? const Center(
                          child: Text("Tap to add image"),
                        )
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter product description" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter quantity" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => submitProduct(),
                child: const Text("Insert Product"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select from"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery),
                child: const Text("Gallery"),
              ),
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.camera),
                child: const Text("Camera"),
              ),
            ],
          ),
        );
      },
    );
  }

  void pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    }
    Navigator.of(context).pop();
  }

  void cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
    );
    if (croppedFile != null) {
      _image = File(croppedFile.path);
      setState(() {});
    }
  }

  void submitProduct() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete all fields and add an image")),
      );
      return;
    }

    final imageBase64 = base64Encode(_image!.readAsBytesSync());
    final response = await http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/insert_product.php"),
      body: {
        'name': nameController.text,
        'description': descriptionController.text,
        'quantity': quantityController.text,
        'price': priceController.text,
        'image': imageBase64,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add product")),
        );
      }
    }
  }
}
