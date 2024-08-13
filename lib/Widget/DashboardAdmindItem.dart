import 'package:flutter/material.dart';

class DashboardAdmindItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Menambahkan ukuran layar
    final screenHeight = MediaQuery.of(context).size.height; // Menambahkan tinggi layar
    return Scaffold(
      body: SingleChildScrollView(
        child: Container( // Menambahkan Container untuk mengatur ukuran
          width: screenWidth, // Mengatur lebar responsif
          height: screenHeight, // Mengatur tinggi responsif
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Masukan Nama',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              SizedBox(height: 20), 
              Container(
                width: screenWidth * 0.9, // Mengatur lebar responsif
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: screenWidth * 0.9, // Mengatur lebar responsif
                        height: 100,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 42,
                      child: Text(
                        'Stok: 100',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 70,
                      child: Text(
                        'Rp. 3.000/pcs',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 10,
                      child: Text(
                        'Indomie',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    ),
                    Positioned(
                      left: screenWidth * 0.8,
                      top: 40,
                      child: Icon( // Mengganti Container dengan Icon
                        Icons.edit, // Menggunakan ikon edit
                        size: 25,
                        color: Colors.red, // Menentukan warna ikon
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}