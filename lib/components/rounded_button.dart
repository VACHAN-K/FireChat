import 'package:flutter/material.dart';

class Rounded_button extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final void Function()? whenPressed;

  Rounded_button(
      {required this.buttonColor,
        required this.buttonText,
        required this.whenPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
            onPressed: whenPressed,
            minWidth: 200.0,
            height: 42.0,
            child: Text(buttonText)),
      ),
    );
  }
}