import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    required this.controller,
    this.obscure,
    this.suffix,
    required this.readOnly,
    this.index,
    required this.fillcolor,
  });
  final String? label;
  final String? hint;

  final TextEditingController controller;
  final bool? obscure;
  final Widget? suffix;
  final bool readOnly;
  final int? index;
  final Color fillcolor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.hint == null ? 60 : 40,
      width: widget.hint == null ? null : 120,
      child: TextField(
        keyboardType: widget.index == 1 ? TextInputType.number : null,
        inputFormatters: widget.index == 1
            ? [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        readOnly: widget.readOnly,
        obscureText: widget.obscure ?? false,
        controller: widget.controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 15),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          fillColor: widget.fillcolor,
          filled: true,
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }
}
