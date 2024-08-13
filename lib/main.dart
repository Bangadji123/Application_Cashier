import 'package:application_cashier/Login_&_Register/LoginAdminPage.dart';
import 'package:application_cashier/Login_&_Register/RegisterPage.dart';
import 'package:application_cashier/Login_&_Register/LoginPetugasPage.dart';
import 'package:application_cashier/Page/DasboardAdminPage.dart';
import 'package:application_cashier/Page/DasboardPetugasPage.dart';
import 'package:application_cashier/Page/EditBarangAdminPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPetugasPage(),
        'registerPage': (context) => RegisterPage(),
        'loginadminPage': (context) => LoginAdminPage(),
        'dashboardpetugasPage': (context) => DasboardPetugasPage(),
        'dashboardadmindPage': (context) => DashboardAdminPage(),
        'editbarangadminPage':(context) => EditBarangAdminPage(),
      },
      theme: ThemeData(
        backgroundColor: Colors.white,
      ),
    );
  }
}
