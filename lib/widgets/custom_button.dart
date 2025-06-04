// custom button

import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final Function() onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF47FFA8),
    this.textColor = Colors.white,
    this.width = 250,
    this.height = 100,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        foregroundColor: widget.textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
