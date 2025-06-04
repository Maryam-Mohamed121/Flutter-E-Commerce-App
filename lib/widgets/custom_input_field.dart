// custom input field widget

import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final bool isAddress;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  CustomInputField({
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.isEmail = false,
    this.isPhone = false,
    this.isAddress = false,
    this.validator,
    this.prefixIcon,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: Color(0xFF04C8E0))
              : null,
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF04C8E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF04C8E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF04C8E0)),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF04C8E0),
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}

// #23332C
// #5FD59E
// #638072
// #47FFA8
