import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class CircularBtn extends StatelessWidget {
  const CircularBtn(
      {super.key,
      required this.color,
      required this.icon,
      required this.onPress});

  final Color color;
  final Widget icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: color, // Button color
        child: InkWell(
          // splashColor: Colors.red, // Splash color
          onTap: onPress,
          child: SizedBox(width: 56, height: 56, child: icon),
        ),
      ),
    );
  }
}
