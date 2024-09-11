import 'package:application_cashier/Login/LoginPage.dart';
import 'package:application_cashier/Page/Admin/DasboardAdminPage.dart';
import 'package:application_cashier/Page/Admin/EditBarangAdminPage.dart';
import 'package:application_cashier/Page/Admin/EditUserPage.dart';
import 'package:application_cashier/Page/Admin/TambahBarangAdminPage.dart';
import 'package:application_cashier/Page/Admin/DaftarUserPage.dart';
import 'package:application_cashier/Page/Admin/TambahUserPage.dart';
import 'package:application_cashier/Page/Petugas/DashboardPetugasPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hoptioxfbdryvtrdeetb.supabase.co', // URL Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvcHRpb3hmYmRyeXZ0cmRlZXRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3MTQ0NDMsImV4cCI6MjAzOTI5MDQ0M30.nI_qEukY5F0cnYGieC4M0Rc5esfKK1eVgKcnsuqBO_Y', // Kunci anon
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override 
  Widget build(BuildContext c0ontext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginAdminPage(),
        'tambahuserPage': (context) => TambahUserPage(),
        'loginadminPage': (context) => LoginAdminPage(),
        'dashboardadminPage': (context) => DashboardAdminPage(),
        'dashboardpetugasPage': (context) => DashboardPetugasPage(),
        'editbarangadminPage':(context) => EditBarangAdminPage(product: {},),
        'tambahbarangadminPage':(context) => TambahBarangAdminPage(),
        'daftaruserPage': (context) => DaftarUserPage(),
        'edituserPage': (context) => EditUserPage(user: {},),
      },
      // theme: ThemeData(
      //   backgroundColor: Colors.white,
      // ),
    );
  }
}