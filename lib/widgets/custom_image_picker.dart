import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';

// custom image picker

class CustomImagePicker extends StatefulWidget {
  final Function(Uint8List? webImage, io.File? mobileImage)? onImageSelected;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CustomImagePicker({
    Key? key,
    this.onImageSelected,
    this.size = 50,
    this.backgroundColor = const Color(0xFF04C8E0),
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  Uint8List? _webImage;
  io.File? _mobileImage;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // final uploadInput = html.FileUploadInputElement();
      // uploadInput.accept = 'image/*';
      // uploadInput.click();

      // uploadInput.onChange.listen((event) {
      //   final file = uploadInput.files!.first;
      //   final reader = html.FileReader();

      //   reader.readAsArrayBuffer(file);
      //   reader.onLoadEnd.listen((event) {
      //     setState(() {
      //       _webImage = reader.result as Uint8List;
      //       widget.onImageSelected?.call(_webImage, null);
      //     });
      //   });
      // });
    } else {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _mobileImage = io.File(pickedImage.path);
          widget.onImageSelected?.call(null, _mobileImage);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;

    if (kIsWeb && _webImage != null) {
      image = MemoryImage(_webImage!);
    } else if (!kIsWeb && _mobileImage != null) {
      image = FileImage(_mobileImage!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: widget.size,
          backgroundColor: widget.backgroundColor,
          backgroundImage: image,
          child: image == null
              ? Icon(Icons.person, size: widget.size, color: widget.iconColor)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: widget.size * 0.36,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.camera_alt,
                color: widget.backgroundColor,
                size: widget.size * 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
