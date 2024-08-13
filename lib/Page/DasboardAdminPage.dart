import 'package:application_cashier/Widget/DashboardAdmindItem.dart';
import 'package:application_cashier/Widget/Sidebar.dart';
import 'package:flutter/material.dart';

class DashboardAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: DashboardAdmindItem(),
      ),
    );
  }
}
