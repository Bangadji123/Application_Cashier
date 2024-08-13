import 'package:application_cashier/Widget/EditBarangAdminItem.dart';
import 'package:flutter/material.dart';

class EditBarangAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Barang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 70,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: EditBarangAdminItem(),
      ),
    );
  }
}