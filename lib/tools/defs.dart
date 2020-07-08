
// LOGIN

import 'dart:ui';

import 'package:booquiz/tools/globals.dart';
import 'package:flutter/material.dart';

final String fbProvider = 'FB';
final String appleProvider = 'APPLE';
final String googleProvider = 'GOOGLE';
final String emailProvider = 'EMAIL';

final int usernameMinLength = 3;
final int usernameMaxLength = 16;

// ERROR MESSAGES
String duplicateEmailError = 'Account with current email already exists.';
String usernameWhitespaceError = 'No whitespaces allowed';
String usernameDuplicateError = 'Duplicate username.';
String usernamePickError = 'Please pick a username.';


// COLORS

final Color colorBlueLight = Color.fromRGBO(174, 228, 255, 1); // Light blue
final Color colorPinkDull = Color.fromRGBO(255, 184, 208, 1); // Dull pink
final Color colorBezhevii = Color.fromRGBO(255, 187, 51, 1); // Bezhevii
final Color colorOrangeDark = Color.fromRGBO(255, 179, 26, 1); // Dull orange (Success color)
final Color colorBlueDarkText = Color.fromRGBO(0, 0, 153, .5); // Dark - Dark blue (Text color)

final Color loginTextColor = Colors.black54;

// IMAGES

// Categories
final String categoryRomanceLink = 'assets/images/categories/romance.png';
final String categoryHistoryLink = 'assets/images/categories/history.png';
final String categorySciFiLink = 'assets/images/categories/sci_fi.png';
final String categoryFantasyLink = 'assets/images/categories/fantasy.png';
final String categoryHorrorLink = 'assets/images/categories/horror.png';
final String categoryThrillerLink = 'assets/images/categories/thriller.png';

// Background

final String searchBooksBackgroundImageLink = 'assets/images/background/old_newspaper.jpg';



// ETC

final double mainPadding = dimensions.dim12();