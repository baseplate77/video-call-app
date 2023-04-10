import 'package:flutter/material.dart';

import '../constant.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn(
      {super.key,
      this.color = primaryColor,
      required this.onPress,
      required this.text});

  final Color color;
  final VoidCallback onPress;
  final String text;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
      onPressed: onPress,
      color: color, // Button color
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
