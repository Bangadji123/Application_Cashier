import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                SizedBox(height: 20),
                _buildInputField('Username', controller: _usernameController),
                SizedBox(height: 10),
                _buildInputField('Password', isPassword: true, controller: _passwordController),
                SizedBox(height: 10),
                _buildInputField('Konfirmasi Password', isPassword: true, controller: _confirmPasswordController),
                SizedBox(height: 20),
                _buildRegisterButton(),
                SizedBox(height: 20),
                _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.asset(
        "Image/2.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInputField(String hintText, {bool isPassword = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3FA2F6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Daftar',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Lato',
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Login',
            style: TextStyle(
              color: Color(0xFF3FA2F6),
              fontSize: 16,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _registerUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('tbl_adminpetugas')
          .insert({
            'Nama_Username': username,
            'Password': password,
            'Konfirm_Password': confirmPassword,
          });

      print('Response: $response'); // Tambahkan log ini

      if (response != null && response.error == null) {
        print('User registered: $username');
        Navigator.pushNamed(context, 'dashboardadmindPage');
      } else {
        _showErrorDialog('Registration failed: ${response?.error?.message ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error during registration: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}