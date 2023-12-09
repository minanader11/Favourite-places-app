import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InputImage extends StatefulWidget {
  InputImage({super.key, required this.onPickImage});
  final void Function(File image) onPickImage;
  @override
  State<InputImage> createState() {
    return _InputImageState();
  }
}

class _InputImageState extends State<InputImage> {
  File? _selectedimage;
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedimage = File(pickedImage.path);
    });
    widget.onPickImage(_selectedimage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: Icon(Icons.camera),
      label: Text(
        'Take Picture',
      ),
    );
    if (_selectedimage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedimage!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: content,
    );
  }
}
