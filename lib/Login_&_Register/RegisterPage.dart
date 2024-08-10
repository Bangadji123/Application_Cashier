import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
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
                _buildInputField('Username'),
                SizedBox(height: 10),
                _buildInputField('Password', isPassword: true),
                SizedBox(height: 10),
                _buildInputField('Konfirmasi Password', isPassword: true),
                SizedBox(height: 20),
                _buildRegisterButton(),
                SizedBox(height: 20),
                _buildLoginPrompt(context),
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

  Widget _buildInputField(String hintText, {bool isPassword = false}) {
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
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 18,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none, // Menghapus border
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        // Implementasi logika registrasi
      },
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

  Widget _buildLoginPrompt(BuildContext context) {
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
}
