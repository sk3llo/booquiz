import 'package:flutter/material.dart';
class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
        backgroundColor: Colors.orange.shade300.withOpacity(.5),
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
    );
  }
}
