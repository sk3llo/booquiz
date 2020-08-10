import 'package:booquiz/ui/bottomNavBarPages/home_page.dart';
import 'package:booquiz/ui/login/login_step1.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginStep1(),
      ),
    );
  }

}
