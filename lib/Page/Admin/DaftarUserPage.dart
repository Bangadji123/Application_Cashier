import 'package:application_cashier/Page/Admin/EditUserPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarUserPage extends StatefulWidget {
  const DaftarUserPage({super.key});

  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _supabase
        .from('tbl_adminpetugas')
        .select()
        .order('id', ascending: true);

    setState(() {
      _users = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  Future<void> _refreshUsers() async {
    await _fetchUsers();
  }

  Future<void> _deleteUser(int id) async {
    // Check if there's only one user left
    if (_users.length <= 1) {
      _showErrorSnackBar('Tidak dapat menghapus user terakhir.');
      return;
    }

    // Check if this is the last admin
    final userToDelete = _users.firstWhere((user) => user['id'] == id);
    final remainingAdmins = _users
        .where((user) => user['Role'] == 'Admin' && user['id'] != id)
        .length;

    if (userToDelete['Role'] == 'Admin' && remainingAdmins == 0) {
      _showErrorSnackBar('Tidak dapat menghapus admin terakhir.');
      return;
    }

    await _supabase.from('tbl_adminpetugas').delete().eq('id', id);
    _fetchUsers();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _censorPassword(String password) {
    return '•' * password.length;
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int userId) async {
    // Check if there's only one user left
    if (_users.length <= 1) {
      _showErrorSnackBar('Tidak dapat menghapus user terakhir.');
      return;
    }

    // Check if this is the last admin
    final userToDelete = _users.firstWhere((user) => user['id'] == userId);
    final remainingAdmins = _users
        .where((user) => user['Role'] == 'Admin' && user['id'] != userId)
        .length;

    if (userToDelete['Role'] == 'Admin' && remainingAdmins == 0) {
      _showErrorSnackBar('Tidak dapat menghapus admin terakhir.');
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus user ini?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(userId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 70,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.only(top: 15),
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              user['Nama_Username'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password: ${_censorPassword(user['Password'] ?? '')}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  'Role: ${user['Role'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.green),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditUserPage(user: user),
                                      ),
                                    ).then((_) => _refreshUsers());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(
                                      context, user['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, 'tambahuserPage').then((_) => _refreshUsers());
        },
      ),
    );
  }
}