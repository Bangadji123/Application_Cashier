import 'package:flutter/material.dart';

class SidebarPetugas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: constraints.maxWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.zero,
                ),
                child: SizedBox(height: 100), // Placeholder for header
              ),
              ListTile(
                leading: Icon(Icons.history, size: constraints.maxWidth * 0.1),
                title: Text('History',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, size: constraints.maxWidth * 0.1),
                title: Text('Pengaturan',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, size: constraints.maxWidth * 0.1),
                title: Text('LogOut',
                    style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {
                  showLogoutConfirmationDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacementNamed(context, 'loginadminPage');
              },
            ),
          ],
        );
      },
    );
  }
}
