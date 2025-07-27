import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  const InputField({super.key, required this.controller, required this.hintText});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hint: Text(widget.hintText),
        fillColor: Colors.grey
      ),
    );
  }
}