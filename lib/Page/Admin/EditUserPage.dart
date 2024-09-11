import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const EditUserPage({Key? key, this.user}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureCurrentPassword = true;
  String _selectedRole = 'Admin';
  bool _isLoading = false;
  bool _isChangingPassword = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!['Nama_Username'] ?? '';
      _selectedRole = widget.user!['Role'] ?? 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Tambah User' : 'Edit User',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Username', _nameController),
                if (widget.user != null)
                  CheckboxListTile(
                    title: Text("Ubah Password"),
                    value: _isChangingPassword,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChangingPassword = value!;
                      });
                    },
                  ),
                if (_isChangingPassword || widget.user == null) ...[
                  _buildTextField('Current Password', _currentPasswordController, isPassword: true),
                  _buildTextField('New Password', _passwordController, isPassword: true),
                  _buildTextField('Konfirmasi New Password', _confirmPasswordController, isPassword: true),
                ],
                _buildDropdown(),
                SizedBox(height: 50),
                _buildSubmitButton(screenWidth, screenHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8)),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? (label == 'Current Password' ? _obscureCurrentPassword : (label == 'New Password' ? _obscurePassword : _obscureConfirmPassword)) : false,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      label == 'Current Password'
                          ? (_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off)
                          : (label == 'New Password'
                              ? (_obscurePassword ? Icons.visibility : Icons.visibility_off)
                              : (_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off)),
                    ),
                    onPressed: () {
                      setState(() {
                        if (label == 'Current Password') {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        } else if (label == 'New Password') {
                          _obscurePassword = !_obscurePassword;
                        } else {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }
                      });
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini tidak boleh kosong';
            }
            if (isPassword && value.length < 6) {
              return 'Password harus minimal 6 karakter';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Role',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8)),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          items: ['Admin', 'Petugas'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Silakan pilih role';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _submitForm,
          child: Container(
            width: screenWidth * 0.8,
            height: screenHeight * 0.08,
            decoration: ShapeDecoration(
              color: Color(0xFF3FA2F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              shadows: [
                BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4), spreadRadius: 0),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.user == null ? 'Register' : 'Update',
                      style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Lato', fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isChangingPassword && _passwordController.text != _confirmPasswordController.text) {
        _showPopupDialog('Error', 'New passwords do not match');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Check the number of existing users
        final existingUsers = await _supabase.from('tbl_adminpetugas').select('id');
        final userCount = existingUsers.length;

        if (widget.user == null) {
          // Adding new user
          final existingUsernames = await _supabase
              .from('tbl_adminpetugas')
              .select('Nama_Username')
              .eq('Nama_Username', _nameController.text);

          if (existingUsernames.isNotEmpty) {
            _showPopupDialog('Error', 'Username already exists. Please choose a different username.');
            return;
          }

          await _supabase.from('tbl_adminpetugas').insert({
            'Nama_Username': _nameController.text,
            'Password': _passwordController.text,
            'Konfirm_Password': _confirmPasswordController.text,
            'Role': _selectedRole,
          });

          _showPopupDialog('Success', 'Registration successful', onDismiss: () {
            Navigator.of(context).pop();
          });
        } else {
          // Updating existing user
          if (userCount <= 1 && widget.user!['Role'] == 'Admin' && _selectedRole != 'Admin') {
            _showPopupDialog('Error', 'Cannot change the role of the last admin user.');
            return;
          }

          // Verify current password if changing password
          if (_isChangingPassword) {
            final currentUser = await _supabase
                .from('tbl_adminpetugas')
                .select()
                .eq('id', widget.user!['id'])
                .single();
            if (currentUser['Password'] != _currentPasswordController.text) {
              _showPopupDialog('Error', 'Current password is incorrect.');
              return;
            }
          }

          // Update user information
          final updateData = {
            'Nama_Username': _nameController.text,
            'Role': _selectedRole,
          };

          if (_isChangingPassword) {
            updateData['Password'] = _passwordController.text;
            updateData['Konfirm_Password'] = _confirmPasswordController.text;
          }

          await _supabase.from('tbl_adminpetugas').update(updateData).eq('id', widget.user!['id']);

          _showPopupDialog('Success', 'User updated successfully', onDismiss: () {
            Navigator.of(context).pop();
          });
        }
      } catch (e) {
        _showPopupDialog('Error', '${widget.user == null ? 'Registration' : 'Update'} failed: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPopupDialog(String title, String content, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) onDismiss();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}