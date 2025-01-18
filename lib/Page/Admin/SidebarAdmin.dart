import 'package:flutter/material.dart';

class SidebarAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: ListView(
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
                      child: SizedBox(height: 100),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.history, size: constraints.maxWidth * 0.1),
                      title: Text(
                        'History',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, 'historyPage');
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.person_add, size: constraints.maxWidth * 0.1),
                      title: Text(
                        'Tambah User',
                        style: TextStyle(
                            fontSize: constraints.maxWidth * 0.05,
                            fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, 'daftaruserPage');
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.add, size: constraints.maxWidth * 0.1),
                      title: Text(
                        'Tambah Barang',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, 'tambahbarangadminPage');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings,
                          size: constraints.maxWidth * 0.1),
                      title: Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () {},
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  size: constraints.maxWidth * 0.08,
                  color: Colors.red,
                ),
                title: Text(
                  'LogOut',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.04,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  showLogoutConfirmationDialog(context);
                },
              ),
              SizedBox(height: 20),
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
