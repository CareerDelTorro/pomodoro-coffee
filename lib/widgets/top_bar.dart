import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final double height;
  final Color color;
  final String? text;
  final TextStyle? textStyle;

  const TopBar({
    super.key,
    required this.height,
    required this.color,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: text != null
          ? Text(
              text!,
              style:
                  textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
    );
  }
}
