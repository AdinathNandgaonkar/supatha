import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xff7bdff2),
      secondary: Color(0xffb2f7ef),
      tertiary: Color(0xffeff7f6),
      inversePrimary: Color.fromARGB(255, 73, 150, 181),
    ),
    scaffoldBackgroundColor: const Color(0xffeff7f6));

// ThemeData lightMode = ThemeData(
//     colorScheme: ColorScheme.light(
//         primary: Colors.grey.shade500,
//         secondary: Colors.grey.shade200,
//         tertiary: Colors.white,
//         inversePrimary: Colors.grey.shade900),
//     scaffoldBackgroundColor: Colors.grey.shade300);
