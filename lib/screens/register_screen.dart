import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_image_picker.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _gender = "";
  DateTime _birthDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userList = prefs.getStringList('users') ?? [];
    _users = userList
        .map((userJson) => jsonDecode(userJson) as Map<String, dynamic>)
        .toList();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userList = _users.map((user) => jsonEncode(user)).toList();
    await prefs.setStringList('users', userList);
  }

  void _addUser(Map<String, dynamic> user) {
    _users.add(user);
    _saveUsers();
  }

  bool _emailExists(String email) {
    return _users.any((user) => user['email'] == email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Register to your account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CustomImagePicker(
                  onImageSelected: (webImage, mobileImage) {
                    setState(() {
                      if (mobileImage != null) {
                        _imagePath = mobileImage.path;
                      }
                    });
                  },
                ),
                SizedBox(height: 20),
                CustomInputField(
                  controller: _nameController,
                  labelText: "Name",
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    if (value.length < 3) {
                      return "Name must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  controller: _emailController,
                  labelText: "Email",
                  prefixIcon: Icons.email,
                  isEmail: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  controller: _phoneController,
                  labelText: "Phone",
                  prefixIcon: Icons.phone,
                  isPhone: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone number";
                    }
                    if (value.length != 11 ||
                        !RegExp(r'^01[0125]\d{8}$').hasMatch(value)) {
                      return "Invalid phone number";
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  controller: _passwordController,
                  labelText: "Password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                CustomInputField(
                  controller: _addressController,
                  labelText: "Address",
                  prefixIcon: Icons.location_on,
                  isAddress: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    if (value.length < 10) {
                      return "Address must be at least 10 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF04C8E0)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Enter your Birth Date: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final defaultDate = DateTime(
                            now.year - 18,
                            now.month,
                            now.day,
                          );
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _birthDate.isBefore(now)
                                ? _birthDate
                                : defaultDate,
                            firstDate: DateTime(1900),
                            lastDate: now,
                          );
                          if (picked != null) {
                            setState(() => _birthDate = picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF04C8E0)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${_birthDate.day}/${_birthDate.month}/${_birthDate.year}",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xFF04C8E0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF04C8E0)),
                  ),
                  child: Row(
                    children: [
                      Text("Your Gender: ", style: TextStyle(fontSize: 16)),
                      Radio(
                        value: "male",
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      Icon(Icons.male, size: 20, color: Color(0xFF04C8E0)),
                      Text("Male", style: TextStyle(fontSize: 16)),
                      Radio(
                        value: "female",
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      Icon(Icons.female, size: 20, color: Color(0xFF04C8E0)),
                      Text("Female", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Register",
                  color: Color(0xFF04C8E0),
                  textColor: Colors.white,
                  width: 200,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _loadUsers();

                      if (_emailExists(_emailController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This email is already registered'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final user = {
                        'email': _emailController.text.trim(),
                        'password': _passwordController.text.trim(),
                        'name': _nameController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'address': _addressController.text.trim(),
                        'gender': _gender,
                        'birthDate': _birthDate.toIso8601String(),
                        'imagePath': _imagePath,
                      };

                      _addUser(user);

                      if (_imagePath != null) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('imagePath', _imagePath!);
                      }

                      _nameController.clear();
                      _emailController.clear();
                      _phoneController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                      _addressController.clear();
                      setState(() {
                        _gender = "";
                        _birthDate = DateTime.now();
                        _imagePath = null;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Registration successful!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
