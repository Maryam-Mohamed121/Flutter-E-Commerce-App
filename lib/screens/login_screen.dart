import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import 'bottomnavbar_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userList = prefs.getStringList('users') ?? [];
    setState(() {
      _users = userList
          .map((userJson) => jsonDecode(userJson) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _saveLoginSession(String email, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString('userName', name);

    final matchedUser = _users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (matchedUser.isNotEmpty) {
      await prefs.setString('name', matchedUser['name'] ?? '');
      await prefs.setString('phoneNumber', matchedUser['phone'] ?? '');
      await prefs.setString('address', matchedUser['address'] ?? '');
      await prefs.setString('gender', matchedUser['gender'] ?? '');
      await prefs.setString('birthDate', matchedUser['birthDate'] ?? '');
    }

    if (_rememberMe) {
      await prefs.setString('rememberedEmail', email);
      await prefs.setString('rememberedPassword', _passwordController.text);
    } else {
      await prefs.remove('rememberedEmail');
      await prefs.remove('rememberedPassword');
    }
  }

  void _attemptLogin() async {
    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    final matchedUser = _users.firstWhere(
      (user) =>
          user['email'] == enteredEmail && user['password'] == enteredPassword,
      orElse: () => {},
    );

    if (matchedUser.isNotEmpty) {
      await _saveLoginSession(enteredEmail, matchedUser['name']);
      _emailController.clear();
      _passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 15),
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
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF04C8E0)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            activeColor: Color(0xFF04C8E0),
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF23332C),
                              fontWeight: FontWeight.bold,
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
                        border: Border.all(color: Color(0xFF04C8E0)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF23332C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF04C8E0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    CustomButton(
                      text: "Login",
                      color: Color(0xFF04C8E0),
                      textColor: Colors.white,
                      width: 150,
                      height: 50,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _attemptLogin();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
