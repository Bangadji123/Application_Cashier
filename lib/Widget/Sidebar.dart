import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(
                  'Admin#123',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                accountEmail: const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('Image/profile.png'),
                  ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              ListTile(
                leading: Icon(Icons.history, size: constraints.maxWidth * 0.1),
                title: Text('History', style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.add, size: constraints.maxWidth * 0.1),
                title: Text('Tambah Barang', style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, size: constraints.maxWidth * 0.1),
                title: Text('Pengaturan', style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, size: constraints.maxWidth * 0.1),
                title: Text('LogOut', style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}