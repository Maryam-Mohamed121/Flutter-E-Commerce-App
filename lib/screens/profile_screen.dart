import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _phoneNumberController.text = prefs.getString('phoneNumber') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _gender = prefs.getString('gender') ?? '';
      String? birthDateString = prefs.getString('birthDate');
      if (birthDateString != null) {
        _birthDate = DateTime.tryParse(birthDateString);
      }
      _imagePath = prefs.getString('imagePath');
    });
  }

  Future<void> _saveProfileData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setString('phoneNumber', _phoneNumberController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('gender', _gender ?? '');
      if (_birthDate != null) {
        await prefs.setString('birthDate', _birthDate!.toIso8601String());
      }
      if (_imagePath != null) {
        await prefs.setString('imagePath', _imagePath!);
      }

      final userList = prefs.getStringList('users') ?? [];
      final updatedUsers = userList.map((userJson) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        if (user['email'] == _emailController.text) {
          return jsonEncode({
            ...user,
            'name': _nameController.text,
            'password': _passwordController.text,
            'phone': _phoneNumberController.text,
            'address': _addressController.text,
            'gender': _gender,
            'birthDate': _birthDate?.toIso8601String(),
          });
        }
        return userJson;
      }).toList();
      await prefs.setStringList('users', updatedUsers);

      final rememberedEmail = prefs.getString('rememberedEmail');
      if (rememberedEmail == _emailController.text) {
        await prefs.setString('rememberedPassword', _passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imagePath = pickedImage.path;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text("Yes, Logout", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('email');
      await prefs.remove('userName');
      await prefs.remove('rememberedEmail');
      await prefs.remove('rememberedPassword');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF476A88),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : AssetImage('assets/images/avatar.jpg')
                              as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: Color(0xFF476A88)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                CustomInputField(
                  controller: _nameController,
                  labelText: "Name",
                  prefixIcon: Icons.person,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  controller: _emailController,
                  labelText: "Email",
                  prefixIcon: Icons.email,
                  isEmail: true,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  controller: _passwordController,
                  labelText: "Password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) =>
                      value!.length < 8 ? "Min 8 characters" : null,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  controller: _phoneNumberController,
                  labelText: "Phone Number",
                  prefixIcon: Icons.phone,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                SizedBox(height: 10),
                CustomInputField(
                  controller: _addressController,
                  labelText: "Address",
                  prefixIcon: Icons.location_on,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF476A88)),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            "Male",
                            style: TextStyle(color: Color(0xFF476A88)),
                          ),
                          leading: Radio<String>(
                            value: 'male',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            "Female",
                            style: TextStyle(color: Color(0xFF476A88)),
                          ),
                          leading: Radio<String>(
                            value: 'female',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF476A88)),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF476A88),
                    ),
                    title: Text(
                      _birthDate == null
                          ? "Select Birth Date"
                          : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                      style: TextStyle(color: Color(0xFF476A88)),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _birthDate ?? DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Save Changes",
                  color: Color(0xFF476A88),
                  textColor: Colors.white,
                  width: double.infinity,
                  height: 50,
                  onPressed: () {
                    _saveProfileData();
                  },
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Logout",
                  color: Colors.red.shade600,
                  textColor: Colors.white,
                  width: double.infinity,
                  height: 50,
                  onPressed: _confirmLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
