import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan import Supabase

class LoginAdminPage extends StatelessWidget {
  final SupabaseClient client =
      Supabase.instance.client; // Inisialisasi SupabaseClient
  final TextEditingController usernameController =
      TextEditingController(); // Kontroler untuk username
  final TextEditingController passwordController =
      TextEditingController(); // Kontroler untuk password

  Future<void> login(BuildContext context) async {
    final response = await client.auth.signInWithPassword(
      email: usernameController.text,
      password: passwordController.text,
    );

    try {
      await Supabase.instance.client.from('your_table_name').insert({
        'Nama_Username': usernameController
            .text, // Ganti 'username' dengan 'usernameController.text'
        'Password': passwordController
            .text, // Ganti 'password' dengan 'passwordController.text'
      });
      Navigator.pushNamed(context, 'dashboardadmindPage');
    } // Tambahkan penutup try
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                // Logo
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    "Image/1.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                ),
                SizedBox(height: 40),
                // Username field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: TextField(
                      controller: usernameController, // Tambahkan kontroler
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Password field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: TextField(
                      controller: passwordController, // Tambahkan kontroler
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: () => login(context), // Panggil fungsi login
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3FA2F6),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'registerPage');
                      },
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3FA2F6),
                        ),
                      ),
                    ),
                  ],
                ),
                // Login as staff
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Login sebagai Petugas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3FA2F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
