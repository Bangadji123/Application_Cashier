import 'package:application_cashier/Login_&_Register/LoginAdminPage.dart';
import 'package:application_cashier/Login_&_Register/RegisterPage.dart';
import 'package:application_cashier/Login_&_Register/LoginPetugasPage.dart';
import 'package:application_cashier/Page/DasboardAdminPage.dart';
import 'package:application_cashier/Page/DasboardPetugasPage.dart';
import 'package:application_cashier/Page/EditBarangAdminPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan import Supabase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hoptioxfbdryvtrdeetb.supabase.co', // URL Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvcHRpb3hmYmRyeXZ0cmRlZXRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3MTQ0NDMsImV4cCI6MjAzOTI5MDQ0M30.nI_qEukY5F0cnYGieC4M0Rc5esfKK1eVgKcnsuqBO_Y', // Kunci anon
  );
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
      // theme: ThemeData(
      //   backgroundColor: Colors.white,
      // ),
    );
  }
}