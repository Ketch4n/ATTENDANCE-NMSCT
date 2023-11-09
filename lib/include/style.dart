import 'package:flutter/material.dart';

class Style {
  static Color themecolor = const Color(0xFF2196F3);
  static EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 25.0);
  static EdgeInsets defaultpadding = const EdgeInsets.symmetric(vertical: 8.0);
  static BoxDecoration login = const BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey, Colors.white]));
  static TextStyle link = TextStyle(color: themecolor, fontSize: 16);
  static BorderRadius borderRadius = BorderRadius.circular(50);
  static BorderRadius borderRadius20 = BorderRadius.circular(20);
  static BorderRadius defaultradius = BorderRadius.circular(12);
  static TextStyle text = const TextStyle(
      fontSize: 20, fontFamily: "MontserratBold", color: Colors.white);
  static TextStyle profileText = const TextStyle(
      fontSize: 15, fontFamily: "MontserratBold", color: Colors.black);
  static TextStyle navbartxt = const TextStyle(
      fontSize: 15, fontFamily: "MontserratBold", color: Colors.white);
  static TextStyle duck = const TextStyle(fontSize: 18, color: Colors.black54);
  static InputDecoration textdesign = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: defaultradius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.green),
      borderRadius: defaultradius,
    ),
    fillColor: Colors.grey[200],
    filled: true,
  );

  static BoxDecoration boxdecor = BoxDecoration(
    borderRadius: Style.borderRadius20,
    color: Colors.white,
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(2, 2),
      ),
    ],
  );

  static TextStyle MontserratBold =
      const TextStyle(fontFamily: "MontserratBold");
  static TextStyle MontserratRegular =
      const TextStyle(fontFamily: "MontserratRegular");

  static TextStyle subtitle = TextStyle(color: Colors.grey[600], fontSize: 16);
}
