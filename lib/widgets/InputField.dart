import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final int maxLines;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.maxLines = 1,
  });
  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _showPassword = false;
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      obscureText: widget.obscureText && !_showPassword,
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: _showPassword
                    ? Icon(HugeIcons.strokeRoundedViewOff)
                    : Icon(Icons.remove_red_eye),
              )
            : SizedBox.shrink(),
        hintText: widget.hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: tertiaryColor),
        filled: true,
        fillColor: const Color(0xFFFFFFFF), // Creme color
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Small radius
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}